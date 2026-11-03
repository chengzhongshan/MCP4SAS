/* J3698 do_while_empty_iteration, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3698o; actual=9; do while(actual<0); actual=actual+100; end; run;

data _null_; if 0 then set j3698o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3698 rows=' rows;
else do; set j3698o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3698';
else put 'ERROR: ROUND8_FAIL=J3698 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3698:; quit;
