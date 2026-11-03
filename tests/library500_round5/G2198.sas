/* G2198 rank_high_ties, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data g2198a; do x=1 to 9; output; output; end; run;
proc rank data=g2198a out=g2198b ties=high; var x; ranks position; run;
proc sql; create table g2198o as select sum(position) as actual from g2198b; quit;

data _null_; if 0 then set g2198o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2198 rows=' rows;
else do; set g2198o; if not missing(actual) and abs(actual-(180))<=1e-9*max(1,abs(180)) then put 'ROUND5_PASS=G2198';
else put 'ERROR: ROUND5_FAIL=G2198 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2198:; quit;
