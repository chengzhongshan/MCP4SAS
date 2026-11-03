/* J3675 array_vname_metadata, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3675o; value1=6; value2=2*6; value3=3*6; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;

data _null_; if 0 then set j3675o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3675 rows=' rows;
else do; set j3675o; if not missing(actual) and abs(actual-(84))<=1e-9*max(1,abs(84)) then put 'ROUND8_PASS=J3675';
else put 'ERROR: ROUND8_FAIL=J3675 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3675:; quit;
