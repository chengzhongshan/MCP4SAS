/* T1260 rank_descending_low_ties, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data t1260a; do x=1 to 11; output; output; end; run;
proc rank data=t1260a out=t1260b descending ties=low; var x; ranks position; run;
proc sql; create table t1260o as select sum(position) as actual from t1260b; quit;

data _null_; if 0 then set t1260o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1260 rows=' rows;
else do; set t1260o; if not missing(actual) and abs(actual-(242))<=1e-10*max(1,abs(242)) then put 'ROUND3_PASS=T1260';
else put 'ERROR: ROUND3_FAIL=T1260 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1260:; quit;
