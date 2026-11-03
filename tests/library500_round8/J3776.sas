/* J3776 output_keep_and_rename_order, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data j3776a(keep=original rename=(original=renamed)); original=7; hidden=100; run;
proc sql; create table j3776o as select renamed as actual from j3776a; quit;

data _null_; if 0 then set j3776o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3776 rows=' rows;
else do; set j3776o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3776';
else put 'ERROR: ROUND8_FAIL=J3776 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3776:; quit;
