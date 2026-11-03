/* T1306 date_between_window, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:29 */

data t1306a; do day=0 to 2*7; date='01JAN2020'd+day; output; end; run;
proc sql; create table t1306o as select count(*) as actual from t1306a where date between '01JAN2020'd+7 and '01JAN2020'd+2*7; quit;

data _null_; if 0 then set t1306o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1306 rows=' rows;
else do; set t1306o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1306';
else put 'ERROR: ROUND3_FAIL=T1306 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1306:; quit;
