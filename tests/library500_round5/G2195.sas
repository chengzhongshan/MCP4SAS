/* G2195 rank_high_ties, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data g2195a; do x=1 to 6; output; output; end; run;
proc rank data=g2195a out=g2195b ties=high; var x; ranks position; run;
proc sql; create table g2195o as select sum(position) as actual from g2195b; quit;

data _null_; if 0 then set g2195o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2195 rows=' rows;
else do; set g2195o; if not missing(actual) and abs(actual-(84))<=1e-9*max(1,abs(84)) then put 'ROUND5_PASS=G2195';
else put 'ERROR: ROUND5_FAIL=G2195 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2195:; quit;
