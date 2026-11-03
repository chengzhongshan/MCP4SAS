/* J3572 standard_selected_columns, N=3; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3572a; do x=1 to 3; y=x*x; output; end; run;
proc standard data=j3572a out=j3572b mean=0 std=1; var x; run;
proc sql; create table j3572o as select sum(y) as actual from j3572b; quit;

data _null_; if 0 then set j3572o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3572 rows=' rows;
else do; set j3572o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND8_PASS=J3572';
else put 'ERROR: ROUND8_FAIL=J3572 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3572:; quit;
