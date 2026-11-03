/* J3710 do_until_bottom_test, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3710o; actual=11; do until(actual>=11); actual=actual+1; end; run;

data _null_; if 0 then set j3710o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3710 rows=' rows;
else do; set j3710o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND8_PASS=J3710';
else put 'ERROR: ROUND8_FAIL=J3710 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3710:; quit;
