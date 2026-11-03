/* G2197 rank_high_ties, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data g2197a; do x=1 to 8; output; output; end; run;
proc rank data=g2197a out=g2197b ties=high; var x; ranks position; run;
proc sql; create table g2197o as select sum(position) as actual from g2197b; quit;

data _null_; if 0 then set g2197o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2197 rows=' rows;
else do; set g2197o; if not missing(actual) and abs(actual-(144))<=1e-9*max(1,abs(144)) then put 'ROUND5_PASS=G2197';
else put 'ERROR: ROUND5_FAIL=G2197 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2197:; quit;
