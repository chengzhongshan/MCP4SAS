/* J3556 standard_replace_mean, N=7; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3556a; do x=1 to 7; id=x; output; end; x=.; id=0; output; run;
proc standard data=j3556a out=j3556b mean=7 std=1 replace; var x; run;
data j3556o; set j3556b; if id=0; actual=x; run;

data _null_; if 0 then set j3556o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3556 rows=' rows;
else do; set j3556o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3556';
else put 'ERROR: ROUND8_FAIL=J3556 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3556:; quit;
