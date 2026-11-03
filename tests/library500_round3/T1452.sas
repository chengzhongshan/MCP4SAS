/* T1452 sysfunc_dataset_handle, N=3; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data t1452a; do x=1 to 3; output; end; run;
%let t1452ds=%sysfunc(open(t1452a,i));
%let t1452count=%sysfunc(attrn(&t1452ds,NLOBS));
%let t1452rc=%sysfunc(close(&t1452ds));
data t1452o; actual=&t1452count; run;
%symdel t1452ds t1452count t1452rc;

data _null_; if 0 then set t1452o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1452 rows=' rows;
else do; set t1452o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1452';
else put 'ERROR: ROUND3_FAIL=T1452 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1452:; quit;
