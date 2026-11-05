/* K4205 log_gamma_integer_factorial, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4205o; actual=lgamma(6+1); run;

data _null_; if 0 then set k4205o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4205 rows=' rows;
else do; set k4205o; if not missing(actual) and abs(actual-(6.5792512120101))<=1e-10*max(1,abs(6.5792512120101)) then put 'ROUND10_PASS=K4205';
else put 'ERROR: ROUND10_FAIL=K4205 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4205:; quit;
