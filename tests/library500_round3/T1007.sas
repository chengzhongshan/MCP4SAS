/* T1007 contents_variable_count, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1007a; array x[8] v1-v8; do j=1 to 8; x[j]=j; end; drop j; run;
proc contents data=t1007a out=t1007b noprint; run;
proc sql; create table t1007o as select count(*) as actual from t1007b; quit;

data _null_; if 0 then set t1007o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1007 rows=' rows;
else do; set t1007o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1007';
else put 'ERROR: ROUND3_FAIL=T1007 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1007:; quit;
