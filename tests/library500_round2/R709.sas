/* R709 retain_product, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r709a; do x=1 to 10; output; end; run;
data r709o; set r709a end=last; retain product 1; product=product*x; if last; actual=product; run;

data _null_; if 0 then set r709o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R709 rows=' rows;
else do; set r709o; if not missing(actual) and abs(actual-(3628800))<=1e-10*max(1,abs(3628800)) then put 'ROUND2_PASS=R709';
else put 'ERROR: ROUND2_FAIL=R709 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r709:; quit;
