/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled */
/* How to rename a CAS table */ 

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;

%put  &_sessref_;


data CASWORK.baseball;
   set sashelp.baseball;
run;

%let mydate=20Apr2020;
%put &mydate;
options caslib="casuser";

PROC CAS;
   table.alterTable  /
      caslib="casuser"
      name="baseball"
      rename="baseball&mydate";
quit;
