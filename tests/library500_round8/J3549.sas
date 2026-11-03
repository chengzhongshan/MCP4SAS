/* J3549 tabulate_sum_output, N=10; source: PROC TABULATE by Example.txt:770 */

data j3549a; do x=1 to 10; output; end; run;
proc tabulate data=j3549a out=j3549b; var x; table x*sum; run;
data j3549o; set j3549b; actual=x_sum; run;

data _null_; if 0 then set j3549o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3549 rows=' rows;
else do; set j3549o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND8_PASS=J3549';
else put 'ERROR: ROUND8_FAIL=J3549 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3549:; quit;
