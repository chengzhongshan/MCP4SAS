/* J3566 standard_preserve_missing, N=7; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3566a; do x=1 to 7; output; end; x=.; output; run;
proc standard data=j3566a out=j3566b mean=10 std=2; var x; run;
proc sql; create table j3566o as select sum(missing(x)) as actual from j3566b; quit;

data _null_; if 0 then set j3566o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3566 rows=' rows;
else do; set j3566o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3566';
else put 'ERROR: ROUND8_FAIL=J3566 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3566:; quit;
