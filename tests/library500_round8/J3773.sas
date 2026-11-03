/* J3773 output_keep_and_rename_order, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data j3773a(keep=original rename=(original=renamed)); original=4; hidden=100; run;
proc sql; create table j3773o as select renamed as actual from j3773a; quit;

data _null_; if 0 then set j3773o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3773 rows=' rows;
else do; set j3773o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND8_PASS=J3773';
else put 'ERROR: ROUND8_FAIL=J3773 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3773:; quit;
