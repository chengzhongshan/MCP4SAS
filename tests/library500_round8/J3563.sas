/* J3563 standard_preserve_missing, N=4; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3563a; do x=1 to 4; output; end; x=.; output; run;
proc standard data=j3563a out=j3563b mean=10 std=2; var x; run;
proc sql; create table j3563o as select sum(missing(x)) as actual from j3563b; quit;

data _null_; if 0 then set j3563o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3563 rows=' rows;
else do; set j3563o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3563';
else put 'ERROR: ROUND8_FAIL=J3563 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3563:; quit;
