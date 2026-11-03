/* J3700 do_while_empty_iteration, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3700o; actual=11; do while(actual<0); actual=actual+100; end; run;

data _null_; if 0 then set j3700o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3700 rows=' rows;
else do; set j3700o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3700';
else put 'ERROR: ROUND8_FAIL=J3700 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3700:; quit;
