/* T1454 sysfunc_dataset_handle, N=5; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data t1454a; do x=1 to 5; output; end; run;
%let t1454ds=%sysfunc(open(t1454a,i));
%let t1454count=%sysfunc(attrn(&t1454ds,NLOBS));
%let t1454rc=%sysfunc(close(&t1454ds));
data t1454o; actual=&t1454count; run;
%symdel t1454ds t1454count t1454rc;

data _null_; if 0 then set t1454o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1454 rows=' rows;
else do; set t1454o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1454';
else put 'ERROR: ROUND3_FAIL=T1454 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1454:; quit;
