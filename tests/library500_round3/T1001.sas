/* T1001 contents_variable_count, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1001a; array x[2] v1-v2; do j=1 to 2; x[j]=j; end; drop j; run;
proc contents data=t1001a out=t1001b noprint; run;
proc sql; create table t1001o as select count(*) as actual from t1001b; quit;

data _null_; if 0 then set t1001o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1001 rows=' rows;
else do; set t1001o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1001';
else put 'ERROR: ROUND3_FAIL=T1001 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1001:; quit;
