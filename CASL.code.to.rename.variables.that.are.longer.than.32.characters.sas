/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* Rename a variabl that is longer than 32 characters */
proc cas;
   table.altertable 
         caslib="casuser" name="cas_table"
         columns={{name = "aVariableNameThatIsWayLongerThanThirtyTwo",
				   rename = "ThirtyTwoOrLess"}};
run;
quit;
         
