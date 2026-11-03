/* J3686 whichn_array_position, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3686o; array values{4} a b c d; a=-1; b=-2; c=7; d=-4;
actual=whichn(7,of values{*}); run;

data _null_; if 0 then set j3686o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3686 rows=' rows;
else do; set j3686o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3686';
else put 'ERROR: ROUND8_FAIL=J3686 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3686:; quit;
