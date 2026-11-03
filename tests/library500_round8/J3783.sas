/* J3783 input_rename_before_where, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3783a; do original=1 to 4+2; output; end; run;
data j3783b; set j3783a(rename=(original=renamed) where=(renamed>4)); run;
proc sql; create table j3783o as select sum(renamed) as actual from j3783b; quit;

data _null_; if 0 then set j3783o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3783 rows=' rows;
else do; set j3783o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3783';
else put 'ERROR: ROUND8_FAIL=J3783 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3783:; quit;
