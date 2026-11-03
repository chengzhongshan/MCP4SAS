/* J3543 tabulate_sum_output, N=4; source: PROC TABULATE by Example.txt:770 */

data j3543a; do x=1 to 4; output; end; run;
proc tabulate data=j3543a out=j3543b; var x; table x*sum; run;
data j3543o; set j3543b; actual=x_sum; run;

data _null_; if 0 then set j3543o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3543 rows=' rows;
else do; set j3543o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3543';
else put 'ERROR: ROUND8_FAIL=J3543 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3543:; quit;
