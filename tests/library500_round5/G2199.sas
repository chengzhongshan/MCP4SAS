/* G2199 rank_high_ties, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data g2199a; do x=1 to 10; output; output; end; run;
proc rank data=g2199a out=g2199b ties=high; var x; ranks position; run;
proc sql; create table g2199o as select sum(position) as actual from g2199b; quit;

data _null_; if 0 then set g2199o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2199 rows=' rows;
else do; set g2199o; if not missing(actual) and abs(actual-(220))<=1e-9*max(1,abs(220)) then put 'ROUND5_PASS=G2199';
else put 'ERROR: ROUND5_FAIL=G2199 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2199:; quit;
