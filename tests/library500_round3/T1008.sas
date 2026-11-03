/* T1008 contents_variable_count, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1008a; array x[9] v1-v9; do j=1 to 9; x[j]=j; end; drop j; run;
proc contents data=t1008a out=t1008b noprint; run;
proc sql; create table t1008o as select count(*) as actual from t1008b; quit;

data _null_; if 0 then set t1008o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1008 rows=' rows;
else do; set t1008o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1008';
else put 'ERROR: ROUND3_FAIL=T1008 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1008:; quit;
