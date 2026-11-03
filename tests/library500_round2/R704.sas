/* R704 retain_product, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r704a; do x=1 to 5; output; end; run;
data r704o; set r704a end=last; retain product 1; product=product*x; if last; actual=product; run;

data _null_; if 0 then set r704o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R704 rows=' rows;
else do; set r704o; if not missing(actual) and abs(actual-(120))<=1e-10*max(1,abs(120)) then put 'ROUND2_PASS=R704';
else put 'ERROR: ROUND2_FAIL=R704 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r704:; quit;
