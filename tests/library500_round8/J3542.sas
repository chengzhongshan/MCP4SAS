/* J3542 tabulate_sum_output, N=3; source: PROC TABULATE by Example.txt:770 */

data j3542a; do x=1 to 3; output; end; run;
proc tabulate data=j3542a out=j3542b; var x; table x*sum; run;
data j3542o; set j3542b; actual=x_sum; run;

data _null_; if 0 then set j3542o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3542 rows=' rows;
else do; set j3542o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3542';
else put 'ERROR: ROUND8_FAIL=J3542 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3542:; quit;
