/* T1252 rank_descending_low_ties, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data t1252a; do x=1 to 3; output; output; end; run;
proc rank data=t1252a out=t1252b descending ties=low; var x; ranks position; run;
proc sql; create table t1252o as select sum(position) as actual from t1252b; quit;

data _null_; if 0 then set t1252o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1252 rows=' rows;
else do; set t1252o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND3_PASS=T1252';
else put 'ERROR: ROUND3_FAIL=T1252 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1252:; quit;
