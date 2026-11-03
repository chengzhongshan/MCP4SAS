/* J3552 standard_replace_mean, N=3; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3552a; do x=1 to 3; id=x; output; end; x=.; id=0; output; run;
proc standard data=j3552a out=j3552b mean=3 std=1 replace; var x; run;
data j3552o; set j3552b; if id=0; actual=x; run;

data _null_; if 0 then set j3552o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3552 rows=' rows;
else do; set j3552o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3552';
else put 'ERROR: ROUND8_FAIL=J3552 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3552:; quit;
