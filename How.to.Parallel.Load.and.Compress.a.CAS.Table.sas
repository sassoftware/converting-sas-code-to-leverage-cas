/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled */
/* How to Parallel Load and Compress a CAS Table */
/* cas casauto terminate; */
cas casauto sessopts=(METRICS=TRUE);
/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;

/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;

%put  &_sessref_; 
options msglevel=i;
/* BLOCKSIZE=536870912 (523MB) is required for large CAS tables */
/* This option will reduce the number of open files that is used to load the CAS table */

%let datapath=/path/to/sas7bdat;

proc cas;
  addcaslib /
    datasource={srctype="path"}
    name="sas7bdat"
    path="&datapath" ; 
 run;
  index /
    table={caslib="sas7bdat" name="cars.sas7bdat" singlepass=true
           vars={{name="make"}  
                 {name="MSRP"}
                }
           where='MSRP > 25000'
          }
    casout={caslib="casuser" name="cars_compressed" blockSize=536870912 compress=true replication=0} ;
 run;
  print _status ; 
 run;
  tabledetails /
    caslib="casuser"
    name="cars_compressed" ; 
 run;
quit;

 
