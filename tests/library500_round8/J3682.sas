/* J3682 whichn_array_position, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3682o; array values{4} a b c d; a=-1; b=-2; c=3; d=-4;
actual=whichn(3,of values{*}); run;

data _null_; if 0 then set j3682o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3682 rows=' rows;
else do; set j3682o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3682';
else put 'ERROR: ROUND8_FAIL=J3682 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3682:; quit;
