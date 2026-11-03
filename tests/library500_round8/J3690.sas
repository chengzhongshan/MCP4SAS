/* J3690 whichn_array_position, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3690o; array values{4} a b c d; a=-1; b=-2; c=11; d=-4;
actual=whichn(11,of values{*}); run;

data _null_; if 0 then set j3690o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3690 rows=' rows;
else do; set j3690o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3690';
else put 'ERROR: ROUND8_FAIL=J3690 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3690:; quit;
