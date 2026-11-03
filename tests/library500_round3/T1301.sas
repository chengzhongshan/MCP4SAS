/* T1301 date_between_window, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:29 */

data t1301a; do day=0 to 2*2; date='01JAN2020'd+day; output; end; run;
proc sql; create table t1301o as select count(*) as actual from t1301a where date between '01JAN2020'd+2 and '01JAN2020'd+2*2; quit;

data _null_; if 0 then set t1301o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1301 rows=' rows;
else do; set t1301o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1301';
else put 'ERROR: ROUND3_FAIL=T1301 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1301:; quit;
