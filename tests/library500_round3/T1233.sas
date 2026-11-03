/* T1233 summary_missing_class, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data t1233a; do grp=1 to 4; value=1; output; end; grp=.; output; run;
proc summary data=t1233a nway missing; class grp; var value; output out=t1233b sum=total; run;
proc sql; create table t1233o as select sum(total) as actual from t1233b; quit;

data _null_; if 0 then set t1233o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1233 rows=' rows;
else do; set t1233o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1233';
else put 'ERROR: ROUND3_FAIL=T1233 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1233:; quit;
