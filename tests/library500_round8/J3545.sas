/* J3545 tabulate_sum_output, N=6; source: PROC TABULATE by Example.txt:770 */

data j3545a; do x=1 to 6; output; end; run;
proc tabulate data=j3545a out=j3545b; var x; table x*sum; run;
data j3545o; set j3545b; actual=x_sum; run;

data _null_; if 0 then set j3545o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3545 rows=' rows;
else do; set j3545o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND8_PASS=J3545';
else put 'ERROR: ROUND8_FAIL=J3545 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3545:; quit;
