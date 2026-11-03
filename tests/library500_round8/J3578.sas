/* J3578 standard_selected_columns, N=9; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3578a; do x=1 to 9; y=x*x; output; end; run;
proc standard data=j3578a out=j3578b mean=0 std=1; var x; run;
proc sql; create table j3578o as select sum(y) as actual from j3578b; quit;

data _null_; if 0 then set j3578o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3578 rows=' rows;
else do; set j3578o; if not missing(actual) and abs(actual-(285))<=1e-9*max(1,abs(285)) then put 'ROUND8_PASS=J3578';
else put 'ERROR: ROUND8_FAIL=J3578 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3578:; quit;
