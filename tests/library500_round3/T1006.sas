/* T1006 contents_variable_count, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1006a; array x[7] v1-v7; do j=1 to 7; x[j]=j; end; drop j; run;
proc contents data=t1006a out=t1006b noprint; run;
proc sql; create table t1006o as select count(*) as actual from t1006b; quit;

data _null_; if 0 then set t1006o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1006 rows=' rows;
else do; set t1006o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1006';
else put 'ERROR: ROUND3_FAIL=T1006 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1006:; quit;
