/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/*Start a CAS session*/
/* Author Jesse Behrens */
cas;
caslib _all_ assign;

/*List the CAS Format Libraries that exist*/
cas casauto listformats; 

/*Move cars to work*/
data cars;
  set sashelp.cars;
run;

/*Create a SAS9 format in the work library and create a copy in a CAS FORMAT Library*/
proc format library=work.formats casfmtlib="casformats" ;
   value enginesize
   low - <2.7 = "Very economical"
   2.7 - <4.1 = "Small"
   4.1 - <5.5 = "Medium"
   5.5 - <6.9 = "Large"
   6.9 - high = "Very large";
run;

/*List the CAS Format Libraries that exist - casformats has been created*/
cas casauto listformats;

/*Lets promote it so it will persist into memory and others can use*/
cas casauto promotefmtlib fmtlibname='casformats';

/*We now have a local and global copy*/
cas casauto listformats;

/*We may want to save a SASHDAT copy incase the server gets restarted*/
/*Save the format to casfmt_table.sashdat */
/*SASHDATs are a great place to store formats if an OS users is using them*/
/*We can also autload formats upon server restart: https://go.documentation.sas.com/?docsetId=caldatamgmtcas&docsetTarget=n0jtz261h5qtg7n1j6ql02gd65lo.htm&docsetVersion=3.5&locale=en#p1xlmcq5h0yjuen1t7lgqf70nypy*/
cas casauto savefmtlib fmtlibname='casformats' caslib='formats' table='casfmt_table' replace;

/*Confirm the file exist*/
proc casutil incaslib='formats';
  list files;
quit;

/*Create a file a cas dataset and look at the format work*/

DATA casuser.cars_cas(replace=yes);
  set sashelp.cars;
  format enginesize enginesize.;
run;

proc print data=casuser.cars_cas(obs=10);
var EngineSize;
run;

/*List the CAS Format Libraries that exist*/
cas casauto listformats; 

/*Delete the session format library*/
cas casauto dropfmtlib fmtlibname=CASFORMATS fmtsearchremove;

/*List the CAS Format Libraries that exist*/
cas casauto listformats; 

/*Delete the global format library - right now it gives me a funny note in the log about the format library not being found.
  HOwever it's not listed in the next listformats level*/
cas casauto dropfmtlib fmtlibname=CASFORMATS fmtsearchremove;

/*List the CAS Format Libraries that exist*/
cas casauto listformats; 

/*Load the format from SASHDAT*/
cas casauto addfmtlib fmtlibname=fmthdat             
   caslib=formats
   table=casfmt_table;

/*List the CAS Format Libraries that exist*/
cas casauto listformats; 

/*list fhe formate values in the new format library*/
cas casauto listformats members;
cas casauto listfmtranges fmtname=enginesize;   

DATA casuser.cars_cas(replace=yes);
  set sashelp.cars;
  format enginesize enginesize.;
run;
