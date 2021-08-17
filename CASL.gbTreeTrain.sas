/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled */
/* cas casauto terminate; */
cas;
caslib _all_ assign;

data casuser.baseball;
   set sashelp.baseball;
run;

proc cas;
loadactionset 'decisionTree';
quit;

options caslib=casuser; 

proc cas;
decisionTree.gbtreeTrain /  
	table={name="baseball"}
	target="logSalary"
	casOut={name="GRADBOOST3", replace=true}
inputs={"nAtBat", 
		"nHits", 
		"nHome", 
		"nRuns", 
		"nRBI", 
		"nBB", 
		"YrMajor", 
		"CrAtBat", 
		"CrHits",
		"CrHome",
 		"CrRuns", 
		"CrRbi",
		"CrBB",
		"nOuts",
		"nAssts",
		"nError",
		"Division",
		"League",
		"Position"}
nominals={"Division","League","Position"}
distribution="POISSON"
earlyStop={metric="LOGLOSS"}
encodeName=TRUE
greedy=TRUE
includeMissing=TRUE
lasso=1 
leafSize=5
learningRate=.1
m=5 	 
varImp=TRUE  
;
quit;
