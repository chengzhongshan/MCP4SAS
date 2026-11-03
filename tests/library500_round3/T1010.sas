/* T1010 contents_variable_count, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1010a; array x[11] v1-v11; do j=1 to 11; x[j]=j; end; drop j; run;
proc contents data=t1010a out=t1010b noprint; run;
proc sql; create table t1010o as select count(*) as actual from t1010b; quit;

data _null_; if 0 then set t1010o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1010 rows=' rows;
else do; set t1010o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1010';
else put 'ERROR: ROUND3_FAIL=T1010 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1010:; quit;
