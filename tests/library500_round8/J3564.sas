/* J3564 standard_preserve_missing, N=5; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3564a; do x=1 to 5; output; end; x=.; output; run;
proc standard data=j3564a out=j3564b mean=10 std=2; var x; run;
proc sql; create table j3564o as select sum(missing(x)) as actual from j3564b; quit;

data _null_; if 0 then set j3564o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3564 rows=' rows;
else do; set j3564o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3564';
else put 'ERROR: ROUND8_FAIL=J3564 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3564:; quit;
