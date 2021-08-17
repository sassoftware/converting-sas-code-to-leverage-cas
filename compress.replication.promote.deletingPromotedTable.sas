/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
cas;
caslib _all_ assign;

/* CAS option that display CAS metrics i.e. real time, cpu, memory in the SAS LOG */
options sessopts=(metrics=TRUE);

/* CASLIB for SAS7BDAT data sets */
proc cas;
   table.dropCaslib /
   caslib='sas7bdat' quiet = true;
run;
   table.addCaslib /
   caslib='sas7bdat'
   dataSource={srctype='path'}
   path="/viyafiles/sasss1/data";
run;
quit;

/* How to parallel load and compress a CAS table */
/* COMPRESS=TRUE compresses target table */
/* REPLICATION=0 sets replication of target table to 0 */
/* PROMOTE=YES persists a CAS table between CAS sessions */
proc cas;
   index /
    table={caslib="sas7bdat" name="cars.sas7bdat" singlepass=true 
           vars={{name="make"}  
                 {name="MSRP"}
                }
          }
    casout={caslib="casuser" name="cars_compressed" blockSize=536870912 compress=true replication=0 promote=true} ;
 run;
quit;


/* DATA Step */
/* COMPRESS=YES compresses target table */
/* COPIES=0 sets replication of target table to 0 */
/* PROMOTE=YES persists a CAS table between CAS sessions */
data casuser.test_datastep (compress=yes copies=0 promote=yes);
    set casuser.cars_compressed;
run;

/* FedSQL */
/* REPLACE=TRUE replaces target table */
/* COMPRESS=YES compresses target table */
/* COPIES=0 sets replication of target table to 0 */
/* Note: PROMOTE= is not supported */
proc fedsql sessref=casauto;
   create table test_fedsql {options replace=true compress=true copies=0}
   as select * from casuser.cars_compressed;
quit;

/* CASUTIL */
/* PROMOTE statement persists a CAS table between CAS sessions */
proc casutil outcaslib="casuser";               
   promote casdata="test_fedsql";
run;

/* How to delete a promoted CAS table */
proc casutil;         
   droptable  casdata="cars_compressed" incaslib="casuser";
   droptable  casdata="test_datastep" incaslib="casuser";
   droptable casdata="test_fedsql" incaslib="casuser";
run;
quit;
