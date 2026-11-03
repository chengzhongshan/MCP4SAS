/* J3671 array_vname_metadata, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3671o; value1=2; value2=2*2; value3=3*2; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;

data _null_; if 0 then set j3671o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3671 rows=' rows;
else do; set j3671o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND8_PASS=J3671';
else put 'ERROR: ROUND8_FAIL=J3671 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3671:; quit;
