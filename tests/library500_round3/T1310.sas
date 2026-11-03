/* T1310 date_between_window, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:29 */

data t1310a; do day=0 to 2*11; date='01JAN2020'd+day; output; end; run;
proc sql; create table t1310o as select count(*) as actual from t1310a where date between '01JAN2020'd+11 and '01JAN2020'd+2*11; quit;

data _null_; if 0 then set t1310o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1310 rows=' rows;
else do; set t1310o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1310';
else put 'ERROR: ROUND3_FAIL=T1310 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1310:; quit;
