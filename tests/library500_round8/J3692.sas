/* J3692 do_while_empty_iteration, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3692o; actual=3; do while(actual<0); actual=actual+100; end; run;

data _null_; if 0 then set j3692o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3692 rows=' rows;
else do; set j3692o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3692';
else put 'ERROR: ROUND8_FAIL=J3692 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3692:; quit;
