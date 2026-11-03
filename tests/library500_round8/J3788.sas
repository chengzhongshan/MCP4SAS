/* J3788 input_rename_before_where, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3788a; do original=1 to 9+2; output; end; run;
data j3788b; set j3788a(rename=(original=renamed) where=(renamed>9)); run;
proc sql; create table j3788o as select sum(renamed) as actual from j3788b; quit;

data _null_; if 0 then set j3788o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3788 rows=' rows;
else do; set j3788o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND8_PASS=J3788';
else put 'ERROR: ROUND8_FAIL=J3788 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3788:; quit;
