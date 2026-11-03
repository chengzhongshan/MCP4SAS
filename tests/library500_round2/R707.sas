/* R707 retain_product, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r707a; do x=1 to 8; output; end; run;
data r707o; set r707a end=last; retain product 1; product=product*x; if last; actual=product; run;

data _null_; if 0 then set r707o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R707 rows=' rows;
else do; set r707o; if not missing(actual) and abs(actual-(40320))<=1e-10*max(1,abs(40320)) then put 'ROUND2_PASS=R707';
else put 'ERROR: ROUND2_FAIL=R707 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r707:; quit;
