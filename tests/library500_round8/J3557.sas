/* J3557 standard_replace_mean, N=8; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3557a; do x=1 to 8; id=x; output; end; x=.; id=0; output; run;
proc standard data=j3557a out=j3557b mean=8 std=1 replace; var x; run;
data j3557o; set j3557b; if id=0; actual=x; run;

data _null_; if 0 then set j3557o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3557 rows=' rows;
else do; set j3557o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND8_PASS=J3557';
else put 'ERROR: ROUND8_FAIL=J3557 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3557:; quit;
