/* J3782 input_rename_before_where, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3782a; do original=1 to 3+2; output; end; run;
data j3782b; set j3782a(rename=(original=renamed) where=(renamed>3)); run;
proc sql; create table j3782o as select sum(renamed) as actual from j3782b; quit;

data _null_; if 0 then set j3782o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3782 rows=' rows;
else do; set j3782o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3782';
else put 'ERROR: ROUND8_FAIL=J3782 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3782:; quit;
