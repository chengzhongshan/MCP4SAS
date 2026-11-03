/* T1004 contents_variable_count, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1004a; array x[5] v1-v5; do j=1 to 5; x[j]=j; end; drop j; run;
proc contents data=t1004a out=t1004b noprint; run;
proc sql; create table t1004o as select count(*) as actual from t1004b; quit;

data _null_; if 0 then set t1004o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1004 rows=' rows;
else do; set t1004o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1004';
else put 'ERROR: ROUND3_FAIL=T1004 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1004:; quit;
