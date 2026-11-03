/* J3778 output_keep_and_rename_order, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data j3778a(keep=original rename=(original=renamed)); original=9; hidden=100; run;
proc sql; create table j3778o as select renamed as actual from j3778a; quit;

data _null_; if 0 then set j3778o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3778 rows=' rows;
else do; set j3778o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3778';
else put 'ERROR: ROUND8_FAIL=J3778 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3778:; quit;
