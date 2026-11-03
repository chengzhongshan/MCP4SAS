/* T1431 symexist_after_symdel, N=2; source: SAS-Useful-Codes/Macros/CaculateMulteQTLs_in_GTEx.sas:46 */

%let t1431value=2;
data t1431a; actual=&t1431value+%symexist(t1431value); run;
%symdel t1431value;
data t1431o; set t1431a; actual=actual+%symexist(t1431value); run;

data _null_; if 0 then set t1431o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1431 rows=' rows;
else do; set t1431o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1431';
else put 'ERROR: ROUND3_FAIL=T1431 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1431:; quit;
