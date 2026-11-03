/* J3677 array_vname_metadata, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3677o; value1=8; value2=2*8; value3=3*8; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;

data _null_; if 0 then set j3677o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3677 rows=' rows;
else do; set j3677o; if not missing(actual) and abs(actual-(112))<=1e-9*max(1,abs(112)) then put 'ROUND8_PASS=J3677';
else put 'ERROR: ROUND8_FAIL=J3677 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3677:; quit;
