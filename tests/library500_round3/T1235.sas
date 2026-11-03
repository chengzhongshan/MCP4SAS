/* T1235 summary_missing_class, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data t1235a; do grp=1 to 6; value=1; output; end; grp=.; output; run;
proc summary data=t1235a nway missing; class grp; var value; output out=t1235b sum=total; run;
proc sql; create table t1235o as select sum(total) as actual from t1235b; quit;

data _null_; if 0 then set t1235o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1235 rows=' rows;
else do; set t1235o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1235';
else put 'ERROR: ROUND3_FAIL=T1235 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1235:; quit;
