/* J3706 do_until_bottom_test, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3706o; actual=7; do until(actual>=7); actual=actual+1; end; run;

data _null_; if 0 then set j3706o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3706 rows=' rows;
else do; set j3706o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND8_PASS=J3706';
else put 'ERROR: ROUND8_FAIL=J3706 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3706:; quit;
