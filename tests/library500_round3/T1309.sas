/* T1309 date_between_window, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:29 */

data t1309a; do day=0 to 2*10; date='01JAN2020'd+day; output; end; run;
proc sql; create table t1309o as select count(*) as actual from t1309a where date between '01JAN2020'd+10 and '01JAN2020'd+2*10; quit;

data _null_; if 0 then set t1309o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1309 rows=' rows;
else do; set t1309o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1309';
else put 'ERROR: ROUND3_FAIL=T1309 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1309:; quit;
