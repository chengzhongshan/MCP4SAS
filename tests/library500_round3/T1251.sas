/* T1251 rank_descending_low_ties, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data t1251a; do x=1 to 2; output; output; end; run;
proc rank data=t1251a out=t1251b descending ties=low; var x; ranks position; run;
proc sql; create table t1251o as select sum(position) as actual from t1251b; quit;

data _null_; if 0 then set t1251o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1251 rows=' rows;
else do; set t1251o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1251';
else put 'ERROR: ROUND3_FAIL=T1251 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1251:; quit;
