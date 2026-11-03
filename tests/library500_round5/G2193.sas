/* G2193 rank_high_ties, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data g2193a; do x=1 to 4; output; output; end; run;
proc rank data=g2193a out=g2193b ties=high; var x; ranks position; run;
proc sql; create table g2193o as select sum(position) as actual from g2193b; quit;

data _null_; if 0 then set g2193o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2193 rows=' rows;
else do; set g2193o; if not missing(actual) and abs(actual-(40))<=1e-9*max(1,abs(40)) then put 'ROUND5_PASS=G2193';
else put 'ERROR: ROUND5_FAIL=G2193 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2193:; quit;
