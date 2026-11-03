/* T1308 date_between_window, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:29 */

data t1308a; do day=0 to 2*9; date='01JAN2020'd+day; output; end; run;
proc sql; create table t1308o as select count(*) as actual from t1308a where date between '01JAN2020'd+9 and '01JAN2020'd+2*9; quit;

data _null_; if 0 then set t1308o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1308 rows=' rows;
else do; set t1308o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1308';
else put 'ERROR: ROUND3_FAIL=T1308 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1308:; quit;
