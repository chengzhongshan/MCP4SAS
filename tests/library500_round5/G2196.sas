/* G2196 rank_high_ties, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data g2196a; do x=1 to 7; output; output; end; run;
proc rank data=g2196a out=g2196b ties=high; var x; ranks position; run;
proc sql; create table g2196o as select sum(position) as actual from g2196b; quit;

data _null_; if 0 then set g2196o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2196 rows=' rows;
else do; set g2196o; if not missing(actual) and abs(actual-(112))<=1e-9*max(1,abs(112)) then put 'ROUND5_PASS=G2196';
else put 'ERROR: ROUND5_FAIL=G2196 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2196:; quit;
