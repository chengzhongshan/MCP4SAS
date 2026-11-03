/* J3695 do_while_empty_iteration, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3695o; actual=6; do while(actual<0); actual=actual+100; end; run;

data _null_; if 0 then set j3695o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3695 rows=' rows;
else do; set j3695o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3695';
else put 'ERROR: ROUND8_FAIL=J3695 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3695:; quit;
