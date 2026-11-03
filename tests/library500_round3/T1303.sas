/* T1303 date_between_window, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:29 */

data t1303a; do day=0 to 2*4; date='01JAN2020'd+day; output; end; run;
proc sql; create table t1303o as select count(*) as actual from t1303a where date between '01JAN2020'd+4 and '01JAN2020'd+2*4; quit;

data _null_; if 0 then set t1303o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1303 rows=' rows;
else do; set t1303o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1303';
else put 'ERROR: ROUND3_FAIL=T1303 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1303:; quit;
