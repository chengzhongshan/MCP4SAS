/* J3544 tabulate_sum_output, N=5; source: PROC TABULATE by Example.txt:770 */

data j3544a; do x=1 to 5; output; end; run;
proc tabulate data=j3544a out=j3544b; var x; table x*sum; run;
data j3544o; set j3544b; actual=x_sum; run;

data _null_; if 0 then set j3544o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3544 rows=' rows;
else do; set j3544o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND8_PASS=J3544';
else put 'ERROR: ROUND8_FAIL=J3544 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3544:; quit;
