/* R705 retain_product, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r705a; do x=1 to 6; output; end; run;
data r705o; set r705a end=last; retain product 1; product=product*x; if last; actual=product; run;

data _null_; if 0 then set r705o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R705 rows=' rows;
else do; set r705o; if not missing(actual) and abs(actual-(720))<=1e-10*max(1,abs(720)) then put 'ROUND2_PASS=R705';
else put 'ERROR: ROUND2_FAIL=R705 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r705:; quit;
