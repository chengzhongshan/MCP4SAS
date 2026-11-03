/* G2200 rank_high_ties, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data g2200a; do x=1 to 11; output; output; end; run;
proc rank data=g2200a out=g2200b ties=high; var x; ranks position; run;
proc sql; create table g2200o as select sum(position) as actual from g2200b; quit;

data _null_; if 0 then set g2200o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2200 rows=' rows;
else do; set g2200o; if not missing(actual) and abs(actual-(264))<=1e-9*max(1,abs(264)) then put 'ROUND5_PASS=G2200';
else put 'ERROR: ROUND5_FAIL=G2200 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2200:; quit;
