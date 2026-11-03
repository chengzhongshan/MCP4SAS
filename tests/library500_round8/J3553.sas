/* J3553 standard_replace_mean, N=4; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3553a; do x=1 to 4; id=x; output; end; x=.; id=0; output; run;
proc standard data=j3553a out=j3553b mean=4 std=1 replace; var x; run;
data j3553o; set j3553b; if id=0; actual=x; run;

data _null_; if 0 then set j3553o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3553 rows=' rows;
else do; set j3553o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND8_PASS=J3553';
else put 'ERROR: ROUND8_FAIL=J3553 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3553:; quit;
