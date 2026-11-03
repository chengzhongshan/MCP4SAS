/* R702 retain_product, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r702a; do x=1 to 3; output; end; run;
data r702o; set r702a end=last; retain product 1; product=product*x; if last; actual=product; run;

data _null_; if 0 then set r702o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R702 rows=' rows;
else do; set r702o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R702';
else put 'ERROR: ROUND2_FAIL=R702 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r702:; quit;
