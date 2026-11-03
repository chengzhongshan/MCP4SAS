/* T1439 symexist_after_symdel, N=10; source: SAS-Useful-Codes/Macros/CaculateMulteQTLs_in_GTEx.sas:46 */

%let t1439value=10;
data t1439a; actual=&t1439value+%symexist(t1439value); run;
%symdel t1439value;
data t1439o; set t1439a; actual=actual+%symexist(t1439value); run;

data _null_; if 0 then set t1439o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1439 rows=' rows;
else do; set t1439o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1439';
else put 'ERROR: ROUND3_FAIL=T1439 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1439:; quit;
