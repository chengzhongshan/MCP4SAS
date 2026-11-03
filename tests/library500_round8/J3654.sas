/* J3654 array_nonunit_two_dimensions, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3654o; array cells{-1:1,2:3} _temporary_; actual=0;
do i=-1 to 1; do j=2 to 3; cells{i,j}=5+10*i+j; actual=actual+cells{i,j}; end; end; run;

data _null_; if 0 then set j3654o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3654 rows=' rows;
else do; set j3654o; if not missing(actual) and abs(actual-(45))<=1e-9*max(1,abs(45)) then put 'ROUND8_PASS=J3654';
else put 'ERROR: ROUND8_FAIL=J3654 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3654:; quit;
