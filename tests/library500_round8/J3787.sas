/* J3787 input_rename_before_where, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3787a; do original=1 to 8+2; output; end; run;
data j3787b; set j3787a(rename=(original=renamed) where=(renamed>8)); run;
proc sql; create table j3787o as select sum(renamed) as actual from j3787b; quit;

data _null_; if 0 then set j3787o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3787 rows=' rows;
else do; set j3787o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND8_PASS=J3787';
else put 'ERROR: ROUND8_FAIL=J3787 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3787:; quit;
