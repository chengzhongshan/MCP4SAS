/* J3575 standard_selected_columns, N=6; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3575a; do x=1 to 6; y=x*x; output; end; run;
proc standard data=j3575a out=j3575b mean=0 std=1; var x; run;
proc sql; create table j3575o as select sum(y) as actual from j3575b; quit;

data _null_; if 0 then set j3575o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3575 rows=' rows;
else do; set j3575o; if not missing(actual) and abs(actual-(91))<=1e-9*max(1,abs(91)) then put 'ROUND8_PASS=J3575';
else put 'ERROR: ROUND8_FAIL=J3575 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3575:; quit;
