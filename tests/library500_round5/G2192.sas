/* G2192 rank_high_ties, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data g2192a; do x=1 to 3; output; output; end; run;
proc rank data=g2192a out=g2192b ties=high; var x; ranks position; run;
proc sql; create table g2192o as select sum(position) as actual from g2192b; quit;

data _null_; if 0 then set g2192o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2192 rows=' rows;
else do; set g2192o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND5_PASS=G2192';
else put 'ERROR: ROUND5_FAIL=G2192 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2192:; quit;
