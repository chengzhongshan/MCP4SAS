/* J3781 input_rename_before_where, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3781a; do original=1 to 2+2; output; end; run;
data j3781b; set j3781a(rename=(original=renamed) where=(renamed>2)); run;
proc sql; create table j3781o as select sum(renamed) as actual from j3781b; quit;

data _null_; if 0 then set j3781o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3781 rows=' rows;
else do; set j3781o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3781';
else put 'ERROR: ROUND8_FAIL=J3781 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3781:; quit;
