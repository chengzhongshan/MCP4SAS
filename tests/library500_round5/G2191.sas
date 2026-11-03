/* G2191 rank_high_ties, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data g2191a; do x=1 to 2; output; output; end; run;
proc rank data=g2191a out=g2191b ties=high; var x; ranks position; run;
proc sql; create table g2191o as select sum(position) as actual from g2191b; quit;

data _null_; if 0 then set g2191o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2191 rows=' rows;
else do; set g2191o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND5_PASS=G2191';
else put 'ERROR: ROUND5_FAIL=G2191 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2191:; quit;
