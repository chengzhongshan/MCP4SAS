/* T1240 summary_missing_class, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data t1240a; do grp=1 to 11; value=1; output; end; grp=.; output; run;
proc summary data=t1240a nway missing; class grp; var value; output out=t1240b sum=total; run;
proc sql; create table t1240o as select sum(total) as actual from t1240b; quit;

data _null_; if 0 then set t1240o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1240 rows=' rows;
else do; set t1240o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1240';
else put 'ERROR: ROUND3_FAIL=T1240 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1240:; quit;
