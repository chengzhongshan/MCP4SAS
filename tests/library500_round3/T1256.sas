/* T1256 rank_descending_low_ties, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data t1256a; do x=1 to 7; output; output; end; run;
proc rank data=t1256a out=t1256b descending ties=low; var x; ranks position; run;
proc sql; create table t1256o as select sum(position) as actual from t1256b; quit;

data _null_; if 0 then set t1256o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1256 rows=' rows;
else do; set t1256o; if not missing(actual) and abs(actual-(98))<=1e-10*max(1,abs(98)) then put 'ROUND3_PASS=T1256';
else put 'ERROR: ROUND3_FAIL=T1256 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1256:; quit;
