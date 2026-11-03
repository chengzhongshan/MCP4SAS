/* T1254 rank_descending_low_ties, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data t1254a; do x=1 to 5; output; output; end; run;
proc rank data=t1254a out=t1254b descending ties=low; var x; ranks position; run;
proc sql; create table t1254o as select sum(position) as actual from t1254b; quit;

data _null_; if 0 then set t1254o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1254 rows=' rows;
else do; set t1254o; if not missing(actual) and abs(actual-(50))<=1e-10*max(1,abs(50)) then put 'ROUND3_PASS=T1254';
else put 'ERROR: ROUND3_FAIL=T1254 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1254:; quit;
