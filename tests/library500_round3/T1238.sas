/* T1238 summary_missing_class, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data t1238a; do grp=1 to 9; value=1; output; end; grp=.; output; run;
proc summary data=t1238a nway missing; class grp; var value; output out=t1238b sum=total; run;
proc sql; create table t1238o as select sum(total) as actual from t1238b; quit;

data _null_; if 0 then set t1238o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1238 rows=' rows;
else do; set t1238o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1238';
else put 'ERROR: ROUND3_FAIL=T1238 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1238:; quit;
