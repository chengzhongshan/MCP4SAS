/* J3541 tabulate_sum_output, N=2; source: PROC TABULATE by Example.txt:770 */

data j3541a; do x=1 to 2; output; end; run;
proc tabulate data=j3541a out=j3541b; var x; table x*sum; run;
data j3541o; set j3541b; actual=x_sum; run;

data _null_; if 0 then set j3541o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3541 rows=' rows;
else do; set j3541o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3541';
else put 'ERROR: ROUND8_FAIL=J3541 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3541:; quit;
