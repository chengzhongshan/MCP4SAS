/* B3352 rank_fraction_denominator, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3352a; do x=1 to 3; output; end; run;
proc rank data=b3352a out=b3352b fraction; var x; ranks fraction; run;
proc sql; create table b3352o as select mean(fraction) as actual from b3352b; quit;

data _null_; if 0 then set b3352o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3352 rows=' rows;
else do; set b3352o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-9*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3352';
else put 'ERROR: ROUND7_FAIL=B3352 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3352:; quit;
