/* T1234 summary_missing_class, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data t1234a; do grp=1 to 5; value=1; output; end; grp=.; output; run;
proc summary data=t1234a nway missing; class grp; var value; output out=t1234b sum=total; run;
proc sql; create table t1234o as select sum(total) as actual from t1234b; quit;

data _null_; if 0 then set t1234o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1234 rows=' rows;
else do; set t1234o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1234';
else put 'ERROR: ROUND3_FAIL=T1234 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1234:; quit;
