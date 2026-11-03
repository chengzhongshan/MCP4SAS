/* T1237 summary_missing_class, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data t1237a; do grp=1 to 8; value=1; output; end; grp=.; output; run;
proc summary data=t1237a nway missing; class grp; var value; output out=t1237b sum=total; run;
proc sql; create table t1237o as select sum(total) as actual from t1237b; quit;

data _null_; if 0 then set t1237o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1237 rows=' rows;
else do; set t1237o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1237';
else put 'ERROR: ROUND3_FAIL=T1237 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1237:; quit;
