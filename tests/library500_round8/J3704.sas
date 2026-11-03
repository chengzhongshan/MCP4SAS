/* J3704 do_until_bottom_test, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3704o; actual=5; do until(actual>=5); actual=actual+1; end; run;

data _null_; if 0 then set j3704o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3704 rows=' rows;
else do; set j3704o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3704';
else put 'ERROR: ROUND8_FAIL=J3704 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3704:; quit;
