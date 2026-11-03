/* J3550 tabulate_sum_output, N=11; source: PROC TABULATE by Example.txt:770 */

data j3550a; do x=1 to 11; output; end; run;
proc tabulate data=j3550a out=j3550b; var x; table x*sum; run;
data j3550o; set j3550b; actual=x_sum; run;

data _null_; if 0 then set j3550o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3550 rows=' rows;
else do; set j3550o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND8_PASS=J3550';
else put 'ERROR: ROUND8_FAIL=J3550 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3550:; quit;
