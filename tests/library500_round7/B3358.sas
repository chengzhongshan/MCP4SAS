/* B3358 rank_fraction_denominator, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3358a; do x=1 to 9; output; end; run;
proc rank data=b3358a out=b3358b fraction; var x; ranks fraction; run;
proc sql; create table b3358o as select mean(fraction) as actual from b3358b; quit;

data _null_; if 0 then set b3358o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3358 rows=' rows;
else do; set b3358o; if not missing(actual) and abs(actual-(0.555555555555556))<=1e-9*max(1,abs(0.555555555555556)) then put 'ROUND7_PASS=B3358';
else put 'ERROR: ROUND7_FAIL=B3358 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3358:; quit;
