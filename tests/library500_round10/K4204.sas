/* K4204 log_gamma_integer_factorial, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4204o; actual=lgamma(5+1); run;

data _null_; if 0 then set k4204o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4204 rows=' rows;
else do; set k4204o; if not missing(actual) and abs(actual-(4.78749174278205))<=1e-10*max(1,abs(4.78749174278205)) then put 'ROUND10_PASS=K4204';
else put 'ERROR: ROUND10_FAIL=K4204 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4204:; quit;
