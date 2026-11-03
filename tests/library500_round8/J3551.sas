/* J3551 standard_replace_mean, N=2; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3551a; do x=1 to 2; id=x; output; end; x=.; id=0; output; run;
proc standard data=j3551a out=j3551b mean=2 std=1 replace; var x; run;
data j3551o; set j3551b; if id=0; actual=x; run;

data _null_; if 0 then set j3551o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3551 rows=' rows;
else do; set j3551o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3551';
else put 'ERROR: ROUND8_FAIL=J3551 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3551:; quit;
