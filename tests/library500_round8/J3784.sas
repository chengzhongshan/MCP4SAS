/* J3784 input_rename_before_where, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3784a; do original=1 to 5+2; output; end; run;
data j3784b; set j3784a(rename=(original=renamed) where=(renamed>5)); run;
proc sql; create table j3784o as select sum(renamed) as actual from j3784b; quit;

data _null_; if 0 then set j3784o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3784 rows=' rows;
else do; set j3784o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND8_PASS=J3784';
else put 'ERROR: ROUND8_FAIL=J3784 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3784:; quit;
