/* K4203 log_gamma_integer_factorial, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4203o; actual=lgamma(4+1); run;

data _null_; if 0 then set k4203o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4203 rows=' rows;
else do; set k4203o; if not missing(actual) and abs(actual-(3.17805383034795))<=1e-10*max(1,abs(3.17805383034795)) then put 'ROUND10_PASS=K4203';
else put 'ERROR: ROUND10_FAIL=K4203 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4203:; quit;
