/* B3351 rank_fraction_denominator, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3351a; do x=1 to 2; output; end; run;
proc rank data=b3351a out=b3351b fraction; var x; ranks fraction; run;
proc sql; create table b3351o as select mean(fraction) as actual from b3351b; quit;

data _null_; if 0 then set b3351o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3351 rows=' rows;
else do; set b3351o; if not missing(actual) and abs(actual-(0.75))<=1e-9*max(1,abs(0.75)) then put 'ROUND7_PASS=B3351';
else put 'ERROR: ROUND7_FAIL=B3351 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3351:; quit;
