/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
cas;
caslib _all_ assign;

%put  &_sessref_;


/* CASLIB for SAS7BDAT data sets */
proc cas;
   table.addCaslib /
   caslib='sas7bdat'
   dataSource={srctype='path'}
   path="/viyafiles/sasss1/data";
run;
quit;

/* CASL code to save a CAS table as a compressed sas7bdat */
proc cas;
  table.save / table={name='baseball', caslib='casuser'},                        /*DATA IN-MEMORY*/            
  name='baseball_compressed.sas7bdat', replace=true caslib='sas7bdat',           /*NAME ON DISK*/
  exportOptions={fileType='basesas', debug={'dmsglvli'}, compress='YES'};     /*COMPRESS*/
quit;

libname d "/viyafiles/sasss1/data";
proc contents data=d.baseball_COMPRESSed;
run;

/* CASUTIL code to save a CAS table as a compressed sas7bdat */
proc casutil;
   save casdata='baseball' incaslib='casuser'                                    /*DATA IN-MEMORY*/          
   casout='baseball_COMPRESS3.sas7bdat'  outcaslib='sas7bdat'                    /*NAME on DISK*/               
   exportoptions=(filetype='basesas', compress='yes' debug='dmsglvli')        /*COMPRESS*/
   replace ;
run;
quit;

libname d "/viyafiles/sasss1/data";
proc contents data=d.baseball_COMPRESS3; 
run;
