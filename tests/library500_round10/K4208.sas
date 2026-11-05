/* K4208 log_gamma_integer_factorial, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4208o; actual=lgamma(9+1); run;

data _null_; if 0 then set k4208o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4208 rows=' rows;
else do; set k4208o; if not missing(actual) and abs(actual-(12.8018274800815))<=1e-10*max(1,abs(12.8018274800815)) then put 'ROUND10_PASS=K4208';
else put 'ERROR: ROUND10_FAIL=K4208 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4208:; quit;
