/* J3678 array_vname_metadata, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3678o; value1=9; value2=2*9; value3=3*9; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;

data _null_; if 0 then set j3678o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3678 rows=' rows;
else do; set j3678o; if not missing(actual) and abs(actual-(126))<=1e-9*max(1,abs(126)) then put 'ROUND8_PASS=J3678';
else put 'ERROR: ROUND8_FAIL=J3678 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3678:; quit;
