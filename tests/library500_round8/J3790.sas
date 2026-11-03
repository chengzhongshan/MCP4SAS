/* J3790 input_rename_before_where, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3790a; do original=1 to 11+2; output; end; run;
data j3790b; set j3790a(rename=(original=renamed) where=(renamed>11)); run;
proc sql; create table j3790o as select sum(renamed) as actual from j3790b; quit;

data _null_; if 0 then set j3790o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3790 rows=' rows;
else do; set j3790o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND8_PASS=J3790';
else put 'ERROR: ROUND8_FAIL=J3790 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3790:; quit;
