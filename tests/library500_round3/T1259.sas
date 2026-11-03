/* T1259 rank_descending_low_ties, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data t1259a; do x=1 to 10; output; output; end; run;
proc rank data=t1259a out=t1259b descending ties=low; var x; ranks position; run;
proc sql; create table t1259o as select sum(position) as actual from t1259b; quit;

data _null_; if 0 then set t1259o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1259 rows=' rows;
else do; set t1259o; if not missing(actual) and abs(actual-(200))<=1e-10*max(1,abs(200)) then put 'ROUND3_PASS=T1259';
else put 'ERROR: ROUND3_FAIL=T1259 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1259:; quit;
