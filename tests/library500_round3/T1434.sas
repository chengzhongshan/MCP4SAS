/* T1434 symexist_after_symdel, N=5; source: SAS-Useful-Codes/Macros/CaculateMulteQTLs_in_GTEx.sas:46 */

%let t1434value=5;
data t1434a; actual=&t1434value+%symexist(t1434value); run;
%symdel t1434value;
data t1434o; set t1434a; actual=actual+%symexist(t1434value); run;

data _null_; if 0 then set t1434o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1434 rows=' rows;
else do; set t1434o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1434';
else put 'ERROR: ROUND3_FAIL=T1434 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1434:; quit;
