/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* cas casauto terminate; */
cas;
caslib _all_ assign;

/* WORKPATH contains the path to SASWORK */
%let workpath = %sysfunc(quote(%sysfunc(pathname(work)))) ;
%put &workpath;

data saswork_table_with_char300;
   length a $ 300 b $ 15 c $ 16;
   a='a300'; b='b15' ; c='c16' ; 
   output;
   a='a300300'; b='b151515'; c='c161616'; 
   output;
   c='c161616161616161'; 
   b='b15151515151515';
   a="a300qzwsxedcrfvtgbyhnujmiklopqazwsxedcrfvtgbyhnujmikolp1234567890123456789012345678901234567890"; 
   output;
run;

proc contents data=saswork_table_with_char300;
title "Contents of WORK.SASWORK_TABLE_WITH_CHAR300";
run;

proc cas;
   file log;
   table.dropCaslib /
   caslib='sas7bdat' quiet = true;
 run;
  addcaslib /
    datasource={srctype="path"}
    name="sas7bdat"
    path=&workpath ; 
 run;

proc casutil;
 load casdata="saswork_table_with_char300.sas7bdat" 
 casout="cas_table_with_varchar" 
 outcaslib="casuser"
 importoptions=(filetype="basesas", dtm="auto", debug="dmsglvli", varcharconversion=16) ;
run;
quit;

title;

proc cas;
   sessionProp.setSessOpt /
   caslib="casuser";
run;
   table.columninfo / table="cas_table_with_varchar";
quit;
