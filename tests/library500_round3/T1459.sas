/* T1459 sysfunc_dataset_handle, N=10; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data t1459a; do x=1 to 10; output; end; run;
%let t1459ds=%sysfunc(open(t1459a,i));
%let t1459count=%sysfunc(attrn(&t1459ds,NLOBS));
%let t1459rc=%sysfunc(close(&t1459ds));
data t1459o; actual=&t1459count; run;
%symdel t1459ds t1459count t1459rc;

data _null_; if 0 then set t1459o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1459 rows=' rows;
else do; set t1459o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1459';
else put 'ERROR: ROUND3_FAIL=T1459 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1459:; quit;
