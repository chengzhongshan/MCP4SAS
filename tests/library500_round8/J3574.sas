/* J3574 standard_selected_columns, N=5; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3574a; do x=1 to 5; y=x*x; output; end; run;
proc standard data=j3574a out=j3574b mean=0 std=1; var x; run;
proc sql; create table j3574o as select sum(y) as actual from j3574b; quit;

data _null_; if 0 then set j3574o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3574 rows=' rows;
else do; set j3574o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND8_PASS=J3574';
else put 'ERROR: ROUND8_FAIL=J3574 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3574:; quit;
