/* J3699 do_while_empty_iteration, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3699o; actual=10; do while(actual<0); actual=actual+100; end; run;

data _null_; if 0 then set j3699o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3699 rows=' rows;
else do; set j3699o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3699';
else put 'ERROR: ROUND8_FAIL=J3699 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3699:; quit;
