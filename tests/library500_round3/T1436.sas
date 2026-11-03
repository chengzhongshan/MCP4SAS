/* T1436 symexist_after_symdel, N=7; source: SAS-Useful-Codes/Macros/CaculateMulteQTLs_in_GTEx.sas:46 */

%let t1436value=7;
data t1436a; actual=&t1436value+%symexist(t1436value); run;
%symdel t1436value;
data t1436o; set t1436a; actual=actual+%symexist(t1436value); run;

data _null_; if 0 then set t1436o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1436 rows=' rows;
else do; set t1436o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1436';
else put 'ERROR: ROUND3_FAIL=T1436 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1436:; quit;
