/* J3679 array_vname_metadata, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3679o; value1=10; value2=2*10; value3=3*10; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;

data _null_; if 0 then set j3679o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3679 rows=' rows;
else do; set j3679o; if not missing(actual) and abs(actual-(140))<=1e-9*max(1,abs(140)) then put 'ROUND8_PASS=J3679';
else put 'ERROR: ROUND8_FAIL=J3679 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3679:; quit;
