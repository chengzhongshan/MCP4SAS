/* J3707 do_until_bottom_test, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3707o; actual=8; do until(actual>=8); actual=actual+1; end; run;

data _null_; if 0 then set j3707o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3707 rows=' rows;
else do; set j3707o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3707';
else put 'ERROR: ROUND8_FAIL=J3707 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3707:; quit;
