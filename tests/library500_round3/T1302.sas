/* T1302 date_between_window, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:29 */

data t1302a; do day=0 to 2*3; date='01JAN2020'd+day; output; end; run;
proc sql; create table t1302o as select count(*) as actual from t1302a where date between '01JAN2020'd+3 and '01JAN2020'd+2*3; quit;

data _null_; if 0 then set t1302o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1302 rows=' rows;
else do; set t1302o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1302';
else put 'ERROR: ROUND3_FAIL=T1302 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1302:; quit;
