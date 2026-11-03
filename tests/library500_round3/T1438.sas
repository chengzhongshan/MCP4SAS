/* T1438 symexist_after_symdel, N=9; source: SAS-Useful-Codes/Macros/CaculateMulteQTLs_in_GTEx.sas:46 */

%let t1438value=9;
data t1438a; actual=&t1438value+%symexist(t1438value); run;
%symdel t1438value;
data t1438o; set t1438a; actual=actual+%symexist(t1438value); run;

data _null_; if 0 then set t1438o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1438 rows=' rows;
else do; set t1438o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1438';
else put 'ERROR: ROUND3_FAIL=T1438 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1438:; quit;
