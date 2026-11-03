/* T1255 rank_descending_low_ties, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data t1255a; do x=1 to 6; output; output; end; run;
proc rank data=t1255a out=t1255b descending ties=low; var x; ranks position; run;
proc sql; create table t1255o as select sum(position) as actual from t1255b; quit;

data _null_; if 0 then set t1255o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1255 rows=' rows;
else do; set t1255o; if not missing(actual) and abs(actual-(72))<=1e-10*max(1,abs(72)) then put 'ROUND3_PASS=T1255';
else put 'ERROR: ROUND3_FAIL=T1255 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1255:; quit;
