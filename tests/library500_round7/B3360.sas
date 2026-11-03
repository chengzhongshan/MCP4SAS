/* B3360 rank_fraction_denominator, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3360a; do x=1 to 11; output; end; run;
proc rank data=b3360a out=b3360b fraction; var x; ranks fraction; run;
proc sql; create table b3360o as select mean(fraction) as actual from b3360b; quit;

data _null_; if 0 then set b3360o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3360 rows=' rows;
else do; set b3360o; if not missing(actual) and abs(actual-(0.545454545454545))<=1e-9*max(1,abs(0.545454545454545)) then put 'ROUND7_PASS=B3360';
else put 'ERROR: ROUND7_FAIL=B3360 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3360:; quit;
