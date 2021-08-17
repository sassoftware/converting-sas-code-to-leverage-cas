/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
cas;
caslib _all_ assign;
/* Orginal code authored by Chris Ricciardi */
/* TB, compressedKB,compressedMB,compressedGB,compressedTB added by Steven Sober */
/* You must modify the path in the CASLIB USDA at the bottom of the code */

proc cas;
   builtins.defineActionSet /
      name="tableSizeHuman"                                             
      actions={
      {                                                       
         name="tableStats"                                     
         desc="Multiple Table actions with calculation of CAS table size and datatype frequency count"
         parms={                                              
            {name="caslib" type="string" required=TRUE}
            {name="table" type="string" required=TRUE}
            {name="level" type="string" required=FALSE default="sum"} 
         }
         definition = "                                        
           table.tableInfo result=r status=s /
                caslib=caslib
                name=table;              
            if 0 != s.severity then do;                       
               send_response(s);
            end;                    
            send_response(r);
           run;

           table.tableDetails result=r status=s /
           caslib=caslib
           name=table
           level=level;
           if 0 != s.severity then do;                       
               send_response(s);
           end;                    
           send_response(r);
           run;

           details = findTable(r);
           saveresult details caslib=caslib casout='casdatasize' replace;

           table.fetch result=r status=s /
               table={caslib=caslib name='casdatasize'
                      computedVars={name='KB',name='MB',name='GB',name='TB',
                                    name='compressedKB',name='compressedMB',name='compressedGB',name='compressedTB'}
                      computedVarsProgram='
                                           KB=round(DataSize / (1024),0.01);
                                           MB=round(DataSize / (1024*1024),0.01);
                                           GB=round(DataSize / (1024*1024*1024),0.01);
                                           TB=round(DataSize / (1024*1024*1024*1024),0.01);
                                           compressedKB=round(CompressedSize / (1024),0.01);
                                           compressedMB=round(CompressedSize / (1024*1024),0.01);
                                           compressedGB=round(CompressedSize / (1024*1024*1024),0.01);
                                           compressedTB=round(CompressedSize / (1024*1024*1024*1024),0.01);
                                          '}
               fetchVars={'DataSize', 'VardataSize', 'KB', 'MB', 'GB', 'TB',
                          'CompressedSize', 'compressedKB', 'compressedMB', 'compressedGB', 'compressedTB'};
   
           if 0 != s.severity then do;                       
               send_response(s);
           end;                    
           send_response(r);
           run;

           /*size = round((details[1,6] + details[1,7]) / (1024*1024),0.01);
           print (string)size || 'MB';
           run;*/

           table.columnInfo result=r status=s /
           table={caslib=caslib name=table};
           if 0 != s.severity then do;                       
               send_response(s);
           end;                    
           send_response(r);
           run;

           columns = findTable(r);
           saveresult columns caslib=caslib casout='cascolumns' replace;

           simple.freq result=r status=s / 
           table={caslib=caslib name='cascolumns'}
           inputs={{name='type'}};
           if 0 != s.severity then do;                       
               send_response(s);
           end;                    
           send_response(r);
           run;
         "
      },
      {                                                       
         name="profCols"                                     
         desc="Profile selected columns"
         parms={                                              
            {name="caslib" type="string" required=TRUE}
            {name="table" type="string" required=TRUE}
            {name="col" type="string" unkeyedList=TRUE required=TRUE}
         }
         definition = "                                        
            dataDiscovery.profile result=r status=s /
              table={name=table, caslib=caslib},
              casOut={caslib=caslib, name='profcols', replication=0, replace=True},
              columns=col,
              frequencies=2,
              minmax=2;              
            if 0 != s.severity then do;                       
               send_response(s);
            end;                    
            send_response(r);
         "
      },
      {                                                       
         name="imageMelt"                                     
         desc="Combine image processing detections with cropped images"
         parms={                                              
            {name="caslib" type="string" required=TRUE}
            {name="detections" type="string" required=TRUE}
            {name="cropped" type="string" required=TRUE}
            {name="casout" type="string" required=TRUE}
         }
         definition = "                                        
            table.columnInfo result=r /
            table={name=detections caslib=caslib};
            col_info = findTable(r);
            varlist = {};
            do colname over col_info;
               if length(colname.Column) ge 7 then do;
               obj = substr(colname.Column,1,7);
               end;
               if obj = '_Object' then do;
               tempVar=colname.Column;
               varlist = varlist + {tempVar};
               end;
            end;
            run;

            /*print varlist;
            run;*/

            transpose.transpose / table ={name=detections caslib=caslib groupBy = {'_id_', '_filename_0', '_nObjects_'} 
                      computedVars={name='idvalue'}
                      computedVarsProgram='idvalue=""Values""'}
                      casout = {name='obj_melted' caslib=caslib replace=true replication=0}
                      id = {'idvalue'}
                      let = 0
                      transpose = varlist
                      name = 'ColName';
            run;

            transpose.transpose / table={name='obj_melted' caslib=caslib groupby={'_id_', 'object', '_filename_0', '_nObjects_'}
                      computedVars={{name='object'},{name='type'}}
                      computedVarsProgram=""object=substr(ColName,8,(index(substr(ColName,2),'_')-7));
                                            if type = substr(ColName,(index(substr(ColName,2),'_')+2)) = '' 
                                              then type = 'objname';
                                            else type = substr(ColName,(index(substr(ColName,2),'_')+2));""}
                      casout={name='obj_melted2' caslib=caslib replace=true replication=0}
                      id={'type'}
                      transpose = {'Values'}
                      let = False;
            run;

            table.tableInfo result=r /
            name=cropped;
            tinfo = findTable(r);
            crop = tinfo[1,1];
            /*print 'crop is ' crop;*/
            clib = tinfo[1,18];
            /*print 'clib is ' clib;*/
            run;

            qstring = 'create table ' || clib || '.' || casout || ' {options replace=true replication=0} as select
                t1.*, t2._filename_0, t2._nObjects_, /*cast(t2.object as double) as object,*/ t2.objname,
                cast(t2.height as double) as height, cast(t2.width as double) as width,
                cast(t2.x as double) as x, cast(t2.y as double) as y
                from ' || clib || '.' || crop || ' t1 left join ' || clib || '.obj_melted2 t2
                on (t1._parentId_ = t2._id_ and t1._id_ = cast(t2.object as double))';
            /*print qstring;*/
            run;

            fedsql.execdirect /
                query=qstring;
            run;

            table.tableInfo result=r status=s /
                caslib=caslib
                name='obj_joined';              
                if 0 != s.severity then do;                       
                    send_response(s);
                end;                    
                send_response(r);
            run;

            table.dropTable / caslib=caslib name='obj_melted';
            run;
            table.dropTable / caslib=caslib name='obj_melted2';
            run;
         "
      }
    }
  ; 
run;
quit;

PROC CAS;
   table.addCaslib /
   caslib='UDAS'
   dataSource={srctype='path'}
   path="/viyafiles/sasss1/userDefinedActionSets";
run;
quit;

proc cas;
   builtins.actionSetToTable /
   actionSet="tableSizeHuman"
   casOut={caslib="UDAS" name="tableSizeHuman" replace=True};
run;
   table.save /
   caslib="UDAS"
   table="tableSizeHuman"
   name="tableSizeHuman.sashdat"
   replace=True;
quit;

/* How to call the user define action set tableSizeHuman  */
/* proc cas; */
/*    tableSizeHuman.tableStats / caslib="casuser" table="baseball"; */
/* run; */
