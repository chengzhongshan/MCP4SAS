/* J3547 tabulate_sum_output, N=8; source: PROC TABULATE by Example.txt:770 */

data j3547a; do x=1 to 8; output; end; run;
proc tabulate data=j3547a out=j3547b; var x; table x*sum; run;
data j3547o; set j3547b; actual=x_sum; run;

data _null_; if 0 then set j3547o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3547 rows=' rows;
else do; set j3547o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND8_PASS=J3547';
else put 'ERROR: ROUND8_FAIL=J3547 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3547:; quit;
