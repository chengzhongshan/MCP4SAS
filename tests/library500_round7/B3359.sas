/* B3359 rank_fraction_denominator, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3359a; do x=1 to 10; output; end; run;
proc rank data=b3359a out=b3359b fraction; var x; ranks fraction; run;
proc sql; create table b3359o as select mean(fraction) as actual from b3359b; quit;

data _null_; if 0 then set b3359o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3359 rows=' rows;
else do; set b3359o; if not missing(actual) and abs(actual-(0.55))<=1e-9*max(1,abs(0.55)) then put 'ROUND7_PASS=B3359';
else put 'ERROR: ROUND7_FAIL=B3359 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3359:; quit;
