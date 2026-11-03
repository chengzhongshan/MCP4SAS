/* J3775 output_keep_and_rename_order, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data j3775a(keep=original rename=(original=renamed)); original=6; hidden=100; run;
proc sql; create table j3775o as select renamed as actual from j3775a; quit;

data _null_; if 0 then set j3775o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3775 rows=' rows;
else do; set j3775o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3775';
else put 'ERROR: ROUND8_FAIL=J3775 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3775:; quit;
