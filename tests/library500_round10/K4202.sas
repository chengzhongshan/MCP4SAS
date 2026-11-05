/* K4202 log_gamma_integer_factorial, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4202o; actual=lgamma(3+1); run;

data _null_; if 0 then set k4202o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4202 rows=' rows;
else do; set k4202o; if not missing(actual) and abs(actual-(1.79175946922805))<=1e-10*max(1,abs(1.79175946922805)) then put 'ROUND10_PASS=K4202';
else put 'ERROR: ROUND10_FAIL=K4202 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4202:; quit;
