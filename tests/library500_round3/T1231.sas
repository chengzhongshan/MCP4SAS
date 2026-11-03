/* T1231 summary_missing_class, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data t1231a; do grp=1 to 2; value=1; output; end; grp=.; output; run;
proc summary data=t1231a nway missing; class grp; var value; output out=t1231b sum=total; run;
proc sql; create table t1231o as select sum(total) as actual from t1231b; quit;

data _null_; if 0 then set t1231o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1231 rows=' rows;
else do; set t1231o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1231';
else put 'ERROR: ROUND3_FAIL=T1231 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1231:; quit;
