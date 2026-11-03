/* R703 retain_product, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r703a; do x=1 to 4; output; end; run;
data r703o; set r703a end=last; retain product 1; product=product*x; if last; actual=product; run;

data _null_; if 0 then set r703o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R703 rows=' rows;
else do; set r703o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND2_PASS=R703';
else put 'ERROR: ROUND2_FAIL=R703 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r703:; quit;
