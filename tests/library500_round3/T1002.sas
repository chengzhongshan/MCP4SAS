/* T1002 contents_variable_count, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1002a; array x[3] v1-v3; do j=1 to 3; x[j]=j; end; drop j; run;
proc contents data=t1002a out=t1002b noprint; run;
proc sql; create table t1002o as select count(*) as actual from t1002b; quit;

data _null_; if 0 then set t1002o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1002 rows=' rows;
else do; set t1002o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1002';
else put 'ERROR: ROUND3_FAIL=T1002 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1002:; quit;
