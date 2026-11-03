/* J3785 input_rename_before_where, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3785a; do original=1 to 6+2; output; end; run;
data j3785b; set j3785a(rename=(original=renamed) where=(renamed>6)); run;
proc sql; create table j3785o as select sum(renamed) as actual from j3785b; quit;

data _null_; if 0 then set j3785o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3785 rows=' rows;
else do; set j3785o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND8_PASS=J3785';
else put 'ERROR: ROUND8_FAIL=J3785 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3785:; quit;
