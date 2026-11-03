/* R701 retain_product, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r701a; do x=1 to 2; output; end; run;
data r701o; set r701a end=last; retain product 1; product=product*x; if last; actual=product; run;

data _null_; if 0 then set r701o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R701 rows=' rows;
else do; set r701o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND2_PASS=R701';
else put 'ERROR: ROUND2_FAIL=R701 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r701:; quit;
