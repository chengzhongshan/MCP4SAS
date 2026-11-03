/* J3670 temporary_array_shift_register, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3670o; array queue{3} _temporary_ (0 0 0);
do j=1 to 11+3; queue{3}=queue{2}; queue{2}=queue{1}; queue{1}=j; end;
actual=sum(of queue{*}); run;

data _null_; if 0 then set j3670o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3670 rows=' rows;
else do; set j3670o; if not missing(actual) and abs(actual-(39))<=1e-9*max(1,abs(39)) then put 'ROUND8_PASS=J3670';
else put 'ERROR: ROUND8_FAIL=J3670 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3670:; quit;
