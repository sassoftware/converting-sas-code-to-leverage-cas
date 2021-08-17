/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* How to terminate your CAS session */
/* If you forget to do this do not worry; all cas session have a default time-out setting which is hit after a period of non activity */
/* A good programming habit */
%put  &_sessref_;
cas &_sessref_ terminate;
