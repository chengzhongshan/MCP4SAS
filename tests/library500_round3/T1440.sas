/* T1440 symexist_after_symdel, N=11; source: SAS-Useful-Codes/Macros/CaculateMulteQTLs_in_GTEx.sas:46 */

%let t1440value=11;
data t1440a; actual=&t1440value+%symexist(t1440value); run;
%symdel t1440value;
data t1440o; set t1440a; actual=actual+%symexist(t1440value); run;

data _null_; if 0 then set t1440o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1440 rows=' rows;
else do; set t1440o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1440';
else put 'ERROR: ROUND3_FAIL=T1440 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1440:; quit;
