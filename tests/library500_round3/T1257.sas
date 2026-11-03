/* T1257 rank_descending_low_ties, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data t1257a; do x=1 to 8; output; output; end; run;
proc rank data=t1257a out=t1257b descending ties=low; var x; ranks position; run;
proc sql; create table t1257o as select sum(position) as actual from t1257b; quit;

data _null_; if 0 then set t1257o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1257 rows=' rows;
else do; set t1257o; if not missing(actual) and abs(actual-(128))<=1e-10*max(1,abs(128)) then put 'ROUND3_PASS=T1257';
else put 'ERROR: ROUND3_FAIL=T1257 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1257:; quit;
