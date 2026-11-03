/* J3669 temporary_array_shift_register, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3669o; array queue{3} _temporary_ (0 0 0);
do j=1 to 10+3; queue{3}=queue{2}; queue{2}=queue{1}; queue{1}=j; end;
actual=sum(of queue{*}); run;

data _null_; if 0 then set j3669o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3669 rows=' rows;
else do; set j3669o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND8_PASS=J3669';
else put 'ERROR: ROUND8_FAIL=J3669 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3669:; quit;
