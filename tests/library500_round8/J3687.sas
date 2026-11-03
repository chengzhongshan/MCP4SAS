/* J3687 whichn_array_position, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3687o; array values{4} a b c d; a=-1; b=-2; c=8; d=-4;
actual=whichn(8,of values{*}); run;

data _null_; if 0 then set j3687o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3687 rows=' rows;
else do; set j3687o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3687';
else put 'ERROR: ROUND8_FAIL=J3687 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3687:; quit;
