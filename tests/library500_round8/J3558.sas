/* J3558 standard_replace_mean, N=9; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3558a; do x=1 to 9; id=x; output; end; x=.; id=0; output; run;
proc standard data=j3558a out=j3558b mean=9 std=1 replace; var x; run;
data j3558o; set j3558b; if id=0; actual=x; run;

data _null_; if 0 then set j3558o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3558 rows=' rows;
else do; set j3558o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3558';
else put 'ERROR: ROUND8_FAIL=J3558 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3558:; quit;
