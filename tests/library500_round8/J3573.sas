/* J3573 standard_selected_columns, N=4; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3573a; do x=1 to 4; y=x*x; output; end; run;
proc standard data=j3573a out=j3573b mean=0 std=1; var x; run;
proc sql; create table j3573o as select sum(y) as actual from j3573b; quit;

data _null_; if 0 then set j3573o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3573 rows=' rows;
else do; set j3573o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND8_PASS=J3573';
else put 'ERROR: ROUND8_FAIL=J3573 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3573:; quit;
