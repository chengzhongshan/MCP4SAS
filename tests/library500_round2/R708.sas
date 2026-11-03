/* R708 retain_product, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r708a; do x=1 to 9; output; end; run;
data r708o; set r708a end=last; retain product 1; product=product*x; if last; actual=product; run;

data _null_; if 0 then set r708o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R708 rows=' rows;
else do; set r708o; if not missing(actual) and abs(actual-(362880))<=1e-10*max(1,abs(362880)) then put 'ROUND2_PASS=R708';
else put 'ERROR: ROUND2_FAIL=R708 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r708:; quit;
