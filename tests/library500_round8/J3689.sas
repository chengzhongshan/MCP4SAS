/* J3689 whichn_array_position, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3689o; array values{4} a b c d; a=-1; b=-2; c=10; d=-4;
actual=whichn(10,of values{*}); run;

data _null_; if 0 then set j3689o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3689 rows=' rows;
else do; set j3689o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3689';
else put 'ERROR: ROUND8_FAIL=J3689 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3689:; quit;
