/* J3673 array_vname_metadata, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3673o; value1=4; value2=2*4; value3=3*4; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;

data _null_; if 0 then set j3673o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3673 rows=' rows;
else do; set j3673o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND8_PASS=J3673';
else put 'ERROR: ROUND8_FAIL=J3673 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3673:; quit;
