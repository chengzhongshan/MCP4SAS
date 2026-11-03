/* J3555 standard_replace_mean, N=6; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3555a; do x=1 to 6; id=x; output; end; x=.; id=0; output; run;
proc standard data=j3555a out=j3555b mean=6 std=1 replace; var x; run;
data j3555o; set j3555b; if id=0; actual=x; run;

data _null_; if 0 then set j3555o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3555 rows=' rows;
else do; set j3555o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3555';
else put 'ERROR: ROUND8_FAIL=J3555 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3555:; quit;
