/* J3560 standard_replace_mean, N=11; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3560a; do x=1 to 11; id=x; output; end; x=.; id=0; output; run;
proc standard data=j3560a out=j3560b mean=11 std=1 replace; var x; run;
data j3560o; set j3560b; if id=0; actual=x; run;

data _null_; if 0 then set j3560o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3560 rows=' rows;
else do; set j3560o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3560';
else put 'ERROR: ROUND8_FAIL=J3560 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3560:; quit;
