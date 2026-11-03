/* T1457 sysfunc_dataset_handle, N=8; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data t1457a; do x=1 to 8; output; end; run;
%let t1457ds=%sysfunc(open(t1457a,i));
%let t1457count=%sysfunc(attrn(&t1457ds,NLOBS));
%let t1457rc=%sysfunc(close(&t1457ds));
data t1457o; actual=&t1457count; run;
%symdel t1457ds t1457count t1457rc;

data _null_; if 0 then set t1457o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1457 rows=' rows;
else do; set t1457o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1457';
else put 'ERROR: ROUND3_FAIL=T1457 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1457:; quit;
