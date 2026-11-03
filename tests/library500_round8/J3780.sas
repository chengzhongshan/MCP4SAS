/* J3780 output_keep_and_rename_order, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data j3780a(keep=original rename=(original=renamed)); original=11; hidden=100; run;
proc sql; create table j3780o as select renamed as actual from j3780a; quit;

data _null_; if 0 then set j3780o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3780 rows=' rows;
else do; set j3780o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3780';
else put 'ERROR: ROUND8_FAIL=J3780 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3780:; quit;
