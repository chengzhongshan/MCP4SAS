/* T1003 contents_variable_count, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1003a; array x[4] v1-v4; do j=1 to 4; x[j]=j; end; drop j; run;
proc contents data=t1003a out=t1003b noprint; run;
proc sql; create table t1003o as select count(*) as actual from t1003b; quit;

data _null_; if 0 then set t1003o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1003 rows=' rows;
else do; set t1003o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1003';
else put 'ERROR: ROUND3_FAIL=T1003 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1003:; quit;
