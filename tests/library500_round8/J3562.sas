/* J3562 standard_preserve_missing, N=3; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3562a; do x=1 to 3; output; end; x=.; output; run;
proc standard data=j3562a out=j3562b mean=10 std=2; var x; run;
proc sql; create table j3562o as select sum(missing(x)) as actual from j3562b; quit;

data _null_; if 0 then set j3562o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3562 rows=' rows;
else do; set j3562o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3562';
else put 'ERROR: ROUND8_FAIL=J3562 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3562:; quit;
