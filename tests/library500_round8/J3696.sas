/* J3696 do_while_empty_iteration, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3696o; actual=7; do while(actual<0); actual=actual+100; end; run;

data _null_; if 0 then set j3696o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3696 rows=' rows;
else do; set j3696o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3696';
else put 'ERROR: ROUND8_FAIL=J3696 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3696:; quit;
