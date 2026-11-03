/* J3771 output_keep_and_rename_order, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data j3771a(keep=original rename=(original=renamed)); original=2; hidden=100; run;
proc sql; create table j3771o as select renamed as actual from j3771a; quit;

data _null_; if 0 then set j3771o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3771 rows=' rows;
else do; set j3771o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3771';
else put 'ERROR: ROUND8_FAIL=J3771 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3771:; quit;
