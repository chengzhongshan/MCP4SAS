/* J3680 array_vname_metadata, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3680o; value1=11; value2=2*11; value3=3*11; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;

data _null_; if 0 then set j3680o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3680 rows=' rows;
else do; set j3680o; if not missing(actual) and abs(actual-(154))<=1e-9*max(1,abs(154)) then put 'ROUND8_PASS=J3680';
else put 'ERROR: ROUND8_FAIL=J3680 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3680:; quit;
