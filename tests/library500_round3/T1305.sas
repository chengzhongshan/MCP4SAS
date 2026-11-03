/* T1305 date_between_window, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:29 */

data t1305a; do day=0 to 2*6; date='01JAN2020'd+day; output; end; run;
proc sql; create table t1305o as select count(*) as actual from t1305a where date between '01JAN2020'd+6 and '01JAN2020'd+2*6; quit;

data _null_; if 0 then set t1305o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1305 rows=' rows;
else do; set t1305o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1305';
else put 'ERROR: ROUND3_FAIL=T1305 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1305:; quit;
