/* K4201 log_gamma_integer_factorial, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4201o; actual=lgamma(2+1); run;

data _null_; if 0 then set k4201o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4201 rows=' rows;
else do; set k4201o; if not missing(actual) and abs(actual-(0.693147180559945))<=1e-10*max(1,abs(0.693147180559945)) then put 'ROUND10_PASS=K4201';
else put 'ERROR: ROUND10_FAIL=K4201 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4201:; quit;
