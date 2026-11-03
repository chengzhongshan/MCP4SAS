/* J3548 tabulate_sum_output, N=9; source: PROC TABULATE by Example.txt:770 */

data j3548a; do x=1 to 9; output; end; run;
proc tabulate data=j3548a out=j3548b; var x; table x*sum; run;
data j3548o; set j3548b; actual=x_sum; run;

data _null_; if 0 then set j3548o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3548 rows=' rows;
else do; set j3548o; if not missing(actual) and abs(actual-(45))<=1e-9*max(1,abs(45)) then put 'ROUND8_PASS=J3548';
else put 'ERROR: ROUND8_FAIL=J3548 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3548:; quit;
