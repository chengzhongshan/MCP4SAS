/* J3554 standard_replace_mean, N=5; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3554a; do x=1 to 5; id=x; output; end; x=.; id=0; output; run;
proc standard data=j3554a out=j3554b mean=5 std=1 replace; var x; run;
data j3554o; set j3554b; if id=0; actual=x; run;

data _null_; if 0 then set j3554o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3554 rows=' rows;
else do; set j3554o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3554';
else put 'ERROR: ROUND8_FAIL=J3554 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3554:; quit;
