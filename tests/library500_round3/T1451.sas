/* T1451 sysfunc_dataset_handle, N=2; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data t1451a; do x=1 to 2; output; end; run;
%let t1451ds=%sysfunc(open(t1451a,i));
%let t1451count=%sysfunc(attrn(&t1451ds,NLOBS));
%let t1451rc=%sysfunc(close(&t1451ds));
data t1451o; actual=&t1451count; run;
%symdel t1451ds t1451count t1451rc;

data _null_; if 0 then set t1451o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1451 rows=' rows;
else do; set t1451o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1451';
else put 'ERROR: ROUND3_FAIL=T1451 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1451:; quit;
