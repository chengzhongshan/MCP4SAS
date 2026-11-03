/* T1307 date_between_window, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:29 */

data t1307a; do day=0 to 2*8; date='01JAN2020'd+day; output; end; run;
proc sql; create table t1307o as select count(*) as actual from t1307a where date between '01JAN2020'd+8 and '01JAN2020'd+2*8; quit;

data _null_; if 0 then set t1307o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1307 rows=' rows;
else do; set t1307o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1307';
else put 'ERROR: ROUND3_FAIL=T1307 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1307:; quit;
