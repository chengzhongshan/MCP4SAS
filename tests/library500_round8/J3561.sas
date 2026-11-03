/* J3561 standard_preserve_missing, N=2; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3561a; do x=1 to 2; output; end; x=.; output; run;
proc standard data=j3561a out=j3561b mean=10 std=2; var x; run;
proc sql; create table j3561o as select sum(missing(x)) as actual from j3561b; quit;

data _null_; if 0 then set j3561o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3561 rows=' rows;
else do; set j3561o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3561';
else put 'ERROR: ROUND8_FAIL=J3561 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3561:; quit;
