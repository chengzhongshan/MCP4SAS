/* J3685 whichn_array_position, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3685o; array values{4} a b c d; a=-1; b=-2; c=6; d=-4;
actual=whichn(6,of values{*}); run;

data _null_; if 0 then set j3685o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3685 rows=' rows;
else do; set j3685o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3685';
else put 'ERROR: ROUND8_FAIL=J3685 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3685:; quit;
