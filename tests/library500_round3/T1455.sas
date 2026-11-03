/* T1455 sysfunc_dataset_handle, N=6; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data t1455a; do x=1 to 6; output; end; run;
%let t1455ds=%sysfunc(open(t1455a,i));
%let t1455count=%sysfunc(attrn(&t1455ds,NLOBS));
%let t1455rc=%sysfunc(close(&t1455ds));
data t1455o; actual=&t1455count; run;
%symdel t1455ds t1455count t1455rc;

data _null_; if 0 then set t1455o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1455 rows=' rows;
else do; set t1455o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1455';
else put 'ERROR: ROUND3_FAIL=T1455 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1455:; quit;
