/* T1460 sysfunc_dataset_handle, N=11; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data t1460a; do x=1 to 11; output; end; run;
%let t1460ds=%sysfunc(open(t1460a,i));
%let t1460count=%sysfunc(attrn(&t1460ds,NLOBS));
%let t1460rc=%sysfunc(close(&t1460ds));
data t1460o; actual=&t1460count; run;
%symdel t1460ds t1460count t1460rc;

data _null_; if 0 then set t1460o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1460 rows=' rows;
else do; set t1460o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1460';
else put 'ERROR: ROUND3_FAIL=T1460 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1460:; quit;
