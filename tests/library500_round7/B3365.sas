/* B3365 rank_nplus1_denominator, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3365a; do x=1 to 6; output; end; run;
proc rank data=b3365a out=b3365b nplus1; var x; ranks fraction; run;
proc sql; create table b3365o as select mean(fraction) as actual from b3365b; quit;

data _null_; if 0 then set b3365o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3365 rows=' rows;
else do; set b3365o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND7_PASS=B3365';
else put 'ERROR: ROUND7_FAIL=B3365 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3365:; quit;
