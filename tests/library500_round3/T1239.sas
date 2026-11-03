/* T1239 summary_missing_class, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data t1239a; do grp=1 to 10; value=1; output; end; grp=.; output; run;
proc summary data=t1239a nway missing; class grp; var value; output out=t1239b sum=total; run;
proc sql; create table t1239o as select sum(total) as actual from t1239b; quit;

data _null_; if 0 then set t1239o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1239 rows=' rows;
else do; set t1239o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1239';
else put 'ERROR: ROUND3_FAIL=T1239 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1239:; quit;
