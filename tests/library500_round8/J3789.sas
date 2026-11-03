/* J3789 input_rename_before_where, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3789a; do original=1 to 10+2; output; end; run;
data j3789b; set j3789a(rename=(original=renamed) where=(renamed>10)); run;
proc sql; create table j3789o as select sum(renamed) as actual from j3789b; quit;

data _null_; if 0 then set j3789o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3789 rows=' rows;
else do; set j3789o; if not missing(actual) and abs(actual-(23))<=1e-9*max(1,abs(23)) then put 'ROUND8_PASS=J3789';
else put 'ERROR: ROUND8_FAIL=J3789 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3789:; quit;
