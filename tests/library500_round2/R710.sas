/* R710 retain_product, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r710a; do x=1 to 11; output; end; run;
data r710o; set r710a end=last; retain product 1; product=product*x; if last; actual=product; run;

data _null_; if 0 then set r710o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R710 rows=' rows;
else do; set r710o; if not missing(actual) and abs(actual-(39916800))<=1e-10*max(1,abs(39916800)) then put 'ROUND2_PASS=R710';
else put 'ERROR: ROUND2_FAIL=R710 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r710:; quit;
