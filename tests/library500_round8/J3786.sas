/* J3786 input_rename_before_where, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3786a; do original=1 to 7+2; output; end; run;
data j3786b; set j3786a(rename=(original=renamed) where=(renamed>7)); run;
proc sql; create table j3786o as select sum(renamed) as actual from j3786b; quit;

data _null_; if 0 then set j3786o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3786 rows=' rows;
else do; set j3786o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND8_PASS=J3786';
else put 'ERROR: ROUND8_FAIL=J3786 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3786:; quit;
