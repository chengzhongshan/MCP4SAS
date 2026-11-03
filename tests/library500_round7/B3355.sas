/* B3355 rank_fraction_denominator, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3355a; do x=1 to 6; output; end; run;
proc rank data=b3355a out=b3355b fraction; var x; ranks fraction; run;
proc sql; create table b3355o as select mean(fraction) as actual from b3355b; quit;

data _null_; if 0 then set b3355o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3355 rows=' rows;
else do; set b3355o; if not missing(actual) and abs(actual-(0.583333333333333))<=1e-9*max(1,abs(0.583333333333333)) then put 'ROUND7_PASS=B3355';
else put 'ERROR: ROUND7_FAIL=B3355 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3355:; quit;
