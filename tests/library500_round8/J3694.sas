/* J3694 do_while_empty_iteration, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3694o; actual=5; do while(actual<0); actual=actual+100; end; run;

data _null_; if 0 then set j3694o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3694 rows=' rows;
else do; set j3694o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3694';
else put 'ERROR: ROUND8_FAIL=J3694 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3694:; quit;
