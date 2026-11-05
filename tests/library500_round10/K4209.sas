/* K4209 log_gamma_integer_factorial, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4209o; actual=lgamma(10+1); run;

data _null_; if 0 then set k4209o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4209 rows=' rows;
else do; set k4209o; if not missing(actual) and abs(actual-(15.1044125730755))<=1e-10*max(1,abs(15.1044125730755)) then put 'ROUND10_PASS=K4209';
else put 'ERROR: ROUND10_FAIL=K4209 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4209:; quit;
