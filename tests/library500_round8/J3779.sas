/* J3779 output_keep_and_rename_order, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data j3779a(keep=original rename=(original=renamed)); original=10; hidden=100; run;
proc sql; create table j3779o as select renamed as actual from j3779a; quit;

data _null_; if 0 then set j3779o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3779 rows=' rows;
else do; set j3779o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3779';
else put 'ERROR: ROUND8_FAIL=J3779 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3779:; quit;
