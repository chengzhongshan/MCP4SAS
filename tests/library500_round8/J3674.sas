/* J3674 array_vname_metadata, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3674o; value1=5; value2=2*5; value3=3*5; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;

data _null_; if 0 then set j3674o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3674 rows=' rows;
else do; set j3674o; if not missing(actual) and abs(actual-(70))<=1e-9*max(1,abs(70)) then put 'ROUND8_PASS=J3674';
else put 'ERROR: ROUND8_FAIL=J3674 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3674:; quit;
