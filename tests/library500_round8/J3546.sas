/* J3546 tabulate_sum_output, N=7; source: PROC TABULATE by Example.txt:770 */

data j3546a; do x=1 to 7; output; end; run;
proc tabulate data=j3546a out=j3546b; var x; table x*sum; run;
data j3546o; set j3546b; actual=x_sum; run;

data _null_; if 0 then set j3546o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3546 rows=' rows;
else do; set j3546o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND8_PASS=J3546';
else put 'ERROR: ROUND8_FAIL=J3546 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3546:; quit;
