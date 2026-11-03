/* T1456 sysfunc_dataset_handle, N=7; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data t1456a; do x=1 to 7; output; end; run;
%let t1456ds=%sysfunc(open(t1456a,i));
%let t1456count=%sysfunc(attrn(&t1456ds,NLOBS));
%let t1456rc=%sysfunc(close(&t1456ds));
data t1456o; actual=&t1456count; run;
%symdel t1456ds t1456count t1456rc;

data _null_; if 0 then set t1456o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1456 rows=' rows;
else do; set t1456o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1456';
else put 'ERROR: ROUND3_FAIL=T1456 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1456:; quit;
