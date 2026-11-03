/* J3676 array_vname_metadata, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3676o; value1=7; value2=2*7; value3=3*7; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;

data _null_; if 0 then set j3676o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3676 rows=' rows;
else do; set j3676o; if not missing(actual) and abs(actual-(98))<=1e-9*max(1,abs(98)) then put 'ROUND8_PASS=J3676';
else put 'ERROR: ROUND8_FAIL=J3676 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3676:; quit;
