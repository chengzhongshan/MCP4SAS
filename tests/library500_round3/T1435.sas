/* T1435 symexist_after_symdel, N=6; source: SAS-Useful-Codes/Macros/CaculateMulteQTLs_in_GTEx.sas:46 */

%let t1435value=6;
data t1435a; actual=&t1435value+%symexist(t1435value); run;
%symdel t1435value;
data t1435o; set t1435a; actual=actual+%symexist(t1435value); run;

data _null_; if 0 then set t1435o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1435 rows=' rows;
else do; set t1435o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1435';
else put 'ERROR: ROUND3_FAIL=T1435 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1435:; quit;
