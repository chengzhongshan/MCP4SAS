/* T1458 sysfunc_dataset_handle, N=9; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data t1458a; do x=1 to 9; output; end; run;
%let t1458ds=%sysfunc(open(t1458a,i));
%let t1458count=%sysfunc(attrn(&t1458ds,NLOBS));
%let t1458rc=%sysfunc(close(&t1458ds));
data t1458o; actual=&t1458count; run;
%symdel t1458ds t1458count t1458rc;

data _null_; if 0 then set t1458o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1458 rows=' rows;
else do; set t1458o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1458';
else put 'ERROR: ROUND3_FAIL=T1458 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1458:; quit;
