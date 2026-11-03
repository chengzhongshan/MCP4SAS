/* J3667 temporary_array_shift_register, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3667o; array queue{3} _temporary_ (0 0 0);
do j=1 to 8+3; queue{3}=queue{2}; queue{2}=queue{1}; queue{1}=j; end;
actual=sum(of queue{*}); run;

data _null_; if 0 then set j3667o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3667 rows=' rows;
else do; set j3667o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND8_PASS=J3667';
else put 'ERROR: ROUND8_FAIL=J3667 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3667:; quit;
