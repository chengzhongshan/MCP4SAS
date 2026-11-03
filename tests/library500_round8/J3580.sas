/* J3580 standard_selected_columns, N=11; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3580a; do x=1 to 11; y=x*x; output; end; run;
proc standard data=j3580a out=j3580b mean=0 std=1; var x; run;
proc sql; create table j3580o as select sum(y) as actual from j3580b; quit;

data _null_; if 0 then set j3580o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3580 rows=' rows;
else do; set j3580o; if not missing(actual) and abs(actual-(506))<=1e-9*max(1,abs(506)) then put 'ROUND8_PASS=J3580';
else put 'ERROR: ROUND8_FAIL=J3580 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3580:; quit;
