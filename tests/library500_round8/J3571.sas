/* J3571 standard_selected_columns, N=2; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3571a; do x=1 to 2; y=x*x; output; end; run;
proc standard data=j3571a out=j3571b mean=0 std=1; var x; run;
proc sql; create table j3571o as select sum(y) as actual from j3571b; quit;

data _null_; if 0 then set j3571o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3571 rows=' rows;
else do; set j3571o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3571';
else put 'ERROR: ROUND8_FAIL=J3571 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3571:; quit;
