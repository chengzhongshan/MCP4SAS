/* J3568 standard_preserve_missing, N=9; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3568a; do x=1 to 9; output; end; x=.; output; run;
proc standard data=j3568a out=j3568b mean=10 std=2; var x; run;
proc sql; create table j3568o as select sum(missing(x)) as actual from j3568b; quit;

data _null_; if 0 then set j3568o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3568 rows=' rows;
else do; set j3568o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3568';
else put 'ERROR: ROUND8_FAIL=J3568 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3568:; quit;
