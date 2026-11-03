/* T1453 sysfunc_dataset_handle, N=4; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data t1453a; do x=1 to 4; output; end; run;
%let t1453ds=%sysfunc(open(t1453a,i));
%let t1453count=%sysfunc(attrn(&t1453ds,NLOBS));
%let t1453rc=%sysfunc(close(&t1453ds));
data t1453o; actual=&t1453count; run;
%symdel t1453ds t1453count t1453rc;

data _null_; if 0 then set t1453o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1453 rows=' rows;
else do; set t1453o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1453';
else put 'ERROR: ROUND3_FAIL=T1453 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1453:; quit;
