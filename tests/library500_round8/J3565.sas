/* J3565 standard_preserve_missing, N=6; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3565a; do x=1 to 6; output; end; x=.; output; run;
proc standard data=j3565a out=j3565b mean=10 std=2; var x; run;
proc sql; create table j3565o as select sum(missing(x)) as actual from j3565b; quit;

data _null_; if 0 then set j3565o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3565 rows=' rows;
else do; set j3565o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3565';
else put 'ERROR: ROUND8_FAIL=J3565 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3565:; quit;
