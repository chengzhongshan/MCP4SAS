/* T1432 symexist_after_symdel, N=3; source: SAS-Useful-Codes/Macros/CaculateMulteQTLs_in_GTEx.sas:46 */

%let t1432value=3;
data t1432a; actual=&t1432value+%symexist(t1432value); run;
%symdel t1432value;
data t1432o; set t1432a; actual=actual+%symexist(t1432value); run;

data _null_; if 0 then set t1432o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1432 rows=' rows;
else do; set t1432o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1432';
else put 'ERROR: ROUND3_FAIL=T1432 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1432:; quit;
