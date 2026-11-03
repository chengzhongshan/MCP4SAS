/* J3774 output_keep_and_rename_order, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data j3774a(keep=original rename=(original=renamed)); original=5; hidden=100; run;
proc sql; create table j3774o as select renamed as actual from j3774a; quit;

data _null_; if 0 then set j3774o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3774 rows=' rows;
else do; set j3774o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3774';
else put 'ERROR: ROUND8_FAIL=J3774 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3774:; quit;
