/* T1258 rank_descending_low_ties, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data t1258a; do x=1 to 9; output; output; end; run;
proc rank data=t1258a out=t1258b descending ties=low; var x; ranks position; run;
proc sql; create table t1258o as select sum(position) as actual from t1258b; quit;

data _null_; if 0 then set t1258o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1258 rows=' rows;
else do; set t1258o; if not missing(actual) and abs(actual-(162))<=1e-10*max(1,abs(162)) then put 'ROUND3_PASS=T1258';
else put 'ERROR: ROUND3_FAIL=T1258 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1258:; quit;
