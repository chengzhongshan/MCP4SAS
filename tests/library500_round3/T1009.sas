/* T1009 contents_variable_count, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1009a; array x[10] v1-v10; do j=1 to 10; x[j]=j; end; drop j; run;
proc contents data=t1009a out=t1009b noprint; run;
proc sql; create table t1009o as select count(*) as actual from t1009b; quit;

data _null_; if 0 then set t1009o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1009 rows=' rows;
else do; set t1009o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1009';
else put 'ERROR: ROUND3_FAIL=T1009 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1009:; quit;
