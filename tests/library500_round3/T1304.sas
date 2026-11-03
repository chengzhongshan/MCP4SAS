/* T1304 date_between_window, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:29 */

data t1304a; do day=0 to 2*5; date='01JAN2020'd+day; output; end; run;
proc sql; create table t1304o as select count(*) as actual from t1304a where date between '01JAN2020'd+5 and '01JAN2020'd+2*5; quit;

data _null_; if 0 then set t1304o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1304 rows=' rows;
else do; set t1304o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1304';
else put 'ERROR: ROUND3_FAIL=T1304 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1304:; quit;
