/* J3569 standard_preserve_missing, N=10; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3569a; do x=1 to 10; output; end; x=.; output; run;
proc standard data=j3569a out=j3569b mean=10 std=2; var x; run;
proc sql; create table j3569o as select sum(missing(x)) as actual from j3569b; quit;

data _null_; if 0 then set j3569o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3569 rows=' rows;
else do; set j3569o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3569';
else put 'ERROR: ROUND8_FAIL=J3569 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3569:; quit;
