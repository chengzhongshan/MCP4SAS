/* J3772 output_keep_and_rename_order, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data j3772a(keep=original rename=(original=renamed)); original=3; hidden=100; run;
proc sql; create table j3772o as select renamed as actual from j3772a; quit;

data _null_; if 0 then set j3772o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3772 rows=' rows;
else do; set j3772o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3772';
else put 'ERROR: ROUND8_FAIL=J3772 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3772:; quit;
