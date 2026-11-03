/* J3576 standard_selected_columns, N=7; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3576a; do x=1 to 7; y=x*x; output; end; run;
proc standard data=j3576a out=j3576b mean=0 std=1; var x; run;
proc sql; create table j3576o as select sum(y) as actual from j3576b; quit;

data _null_; if 0 then set j3576o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3576 rows=' rows;
else do; set j3576o; if not missing(actual) and abs(actual-(140))<=1e-9*max(1,abs(140)) then put 'ROUND8_PASS=J3576';
else put 'ERROR: ROUND8_FAIL=J3576 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3576:; quit;
