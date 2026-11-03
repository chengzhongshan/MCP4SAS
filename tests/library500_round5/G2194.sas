/* G2194 rank_high_ties, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data g2194a; do x=1 to 5; output; output; end; run;
proc rank data=g2194a out=g2194b ties=high; var x; ranks position; run;
proc sql; create table g2194o as select sum(position) as actual from g2194b; quit;

data _null_; if 0 then set g2194o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2194 rows=' rows;
else do; set g2194o; if not missing(actual) and abs(actual-(60))<=1e-9*max(1,abs(60)) then put 'ROUND5_PASS=G2194';
else put 'ERROR: ROUND5_FAIL=G2194 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2194:; quit;
