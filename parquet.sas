/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
cas;
caslib _all_ assign;

%put  &_sessref_;


/* CASLIB for parquet files */
/* Note: The path must be accessible by all CAS worker nodes */
proc cas;
   table.dropCaslib /
   caslib='parquet' quiet = true;
run;
   table.addCaslib /
   caslib='parquet'
   dataSource={srctype='path'}
   path="/viyafiles/sasss1/data";
run;
quit;

/* Load a CAS table */
/* Source is a parquet files */
proc casutil  incaslib="parquet" outcaslib="casuser";
   load casdata="dummy.parquet"  casout="dummy" replace replication=0 ;
run;
quit;

/* Saving a CAS table as a parquet file */
proc casutil  incaslib="casuser"  outcaslib="parquet";
   save casdata="dummy" casout="dummy.parquet" replace ;
run;
quit;

/* Deleting a CAS table */
proc casutil;         
   droptable  casdata="dummy" incaslib="casuser";
run;
quit;

/* Parallel load and compress a CAS table */
/* Source is a parquet files */
proc cas;
   index /
    table={caslib="parquet" name="dummy.parquet" singlepass=true}
    casout={caslib="casuser" name="dummy" blockSize=536870912 compress=true replication=0} ;
 run;
quit;
