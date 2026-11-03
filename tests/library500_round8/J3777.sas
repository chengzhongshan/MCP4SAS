/* J3777 output_keep_and_rename_order, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data j3777a(keep=original rename=(original=renamed)); original=8; hidden=100; run;
proc sql; create table j3777o as select renamed as actual from j3777a; quit;

data _null_; if 0 then set j3777o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3777 rows=' rows;
else do; set j3777o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND8_PASS=J3777';
else put 'ERROR: ROUND8_FAIL=J3777 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3777:; quit;
