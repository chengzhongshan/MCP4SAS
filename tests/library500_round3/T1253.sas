/* T1253 rank_descending_low_ties, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data t1253a; do x=1 to 4; output; output; end; run;
proc rank data=t1253a out=t1253b descending ties=low; var x; ranks position; run;
proc sql; create table t1253o as select sum(position) as actual from t1253b; quit;

data _null_; if 0 then set t1253o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1253 rows=' rows;
else do; set t1253o; if not missing(actual) and abs(actual-(32))<=1e-10*max(1,abs(32)) then put 'ROUND3_PASS=T1253';
else put 'ERROR: ROUND3_FAIL=T1253 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1253:; quit;
