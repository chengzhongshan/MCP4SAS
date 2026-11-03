/* J3693 do_while_empty_iteration, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3693o; actual=4; do while(actual<0); actual=actual+100; end; run;

data _null_; if 0 then set j3693o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3693 rows=' rows;
else do; set j3693o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND8_PASS=J3693';
else put 'ERROR: ROUND8_FAIL=J3693 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3693:; quit;
