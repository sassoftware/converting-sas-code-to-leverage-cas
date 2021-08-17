/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled*/

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

data casuser.cars;
    set sashelp.cars;
run;

/* Set the active CASLIB to CASUSER */
options caslib="casuser";

/* Emulate PROC STDIZE */
proc cas;
    session CASAUTO ;
    transform /
        table = 'cars'
        pipelines = {
            {
                name = 'tr1'
                inputs = {'mpg_city', 'mpg_highway'}
                function = {method = 'range'}
            },
            {
                name = 'tr2'
                inputs = {'weight'}
                function = {method = 'center'}
            },
            {
                name = 'tr2'
                inputs = {'invoice'}
                function = {method = 'standardize' args={location='mean' scale='std'}}
            }
        }
        casout = {name = 'out1', replace=True}
        saveState = {name = 'astore', replace=True}
        /*--- important to keep input names----*/
        outVarsNameGlobalPrefix = ''
        ;
    run;
quit;


