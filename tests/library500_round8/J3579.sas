/* J3579 standard_selected_columns, N=10; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3579a; do x=1 to 10; y=x*x; output; end; run;
proc standard data=j3579a out=j3579b mean=0 std=1; var x; run;
proc sql; create table j3579o as select sum(y) as actual from j3579b; quit;

data _null_; if 0 then set j3579o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3579 rows=' rows;
else do; set j3579o; if not missing(actual) and abs(actual-(385))<=1e-9*max(1,abs(385)) then put 'ROUND8_PASS=J3579';
else put 'ERROR: ROUND8_FAIL=J3579 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3579:; quit;
