/* J3672 array_vname_metadata, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3672o; value1=3; value2=2*3; value3=3*3; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;

data _null_; if 0 then set j3672o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3672 rows=' rows;
else do; set j3672o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND8_PASS=J3672';
else put 'ERROR: ROUND8_FAIL=J3672 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3672:; quit;
