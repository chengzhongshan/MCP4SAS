/* J3663 temporary_array_shift_register, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3663o; array queue{3} _temporary_ (0 0 0);
do j=1 to 4+3; queue{3}=queue{2}; queue{2}=queue{1}; queue{1}=j; end;
actual=sum(of queue{*}); run;

data _null_; if 0 then set j3663o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3663 rows=' rows;
else do; set j3663o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND8_PASS=J3663';
else put 'ERROR: ROUND8_FAIL=J3663 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3663:; quit;
