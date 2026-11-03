/* J3559 standard_replace_mean, N=10; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3559a; do x=1 to 10; id=x; output; end; x=.; id=0; output; run;
proc standard data=j3559a out=j3559b mean=10 std=1 replace; var x; run;
data j3559o; set j3559b; if id=0; actual=x; run;

data _null_; if 0 then set j3559o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3559 rows=' rows;
else do; set j3559o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3559';
else put 'ERROR: ROUND8_FAIL=J3559 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3559:; quit;
