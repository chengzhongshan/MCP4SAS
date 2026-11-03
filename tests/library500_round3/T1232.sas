/* T1232 summary_missing_class, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data t1232a; do grp=1 to 3; value=1; output; end; grp=.; output; run;
proc summary data=t1232a nway missing; class grp; var value; output out=t1232b sum=total; run;
proc sql; create table t1232o as select sum(total) as actual from t1232b; quit;

data _null_; if 0 then set t1232o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1232 rows=' rows;
else do; set t1232o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1232';
else put 'ERROR: ROUND3_FAIL=T1232 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1232:; quit;
