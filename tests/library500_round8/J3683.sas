/* J3683 whichn_array_position, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3683o; array values{4} a b c d; a=-1; b=-2; c=4; d=-4;
actual=whichn(4,of values{*}); run;

data _null_; if 0 then set j3683o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3683 rows=' rows;
else do; set j3683o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3683';
else put 'ERROR: ROUND8_FAIL=J3683 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3683:; quit;
