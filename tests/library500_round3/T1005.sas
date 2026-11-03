/* T1005 contents_variable_count, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1005a; array x[6] v1-v6; do j=1 to 6; x[j]=j; end; drop j; run;
proc contents data=t1005a out=t1005b noprint; run;
proc sql; create table t1005o as select count(*) as actual from t1005b; quit;

data _null_; if 0 then set t1005o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1005 rows=' rows;
else do; set t1005o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1005';
else put 'ERROR: ROUND3_FAIL=T1005 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1005:; quit;
