/* K4206 log_gamma_integer_factorial, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4206o; actual=lgamma(7+1); run;

data _null_; if 0 then set k4206o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4206 rows=' rows;
else do; set k4206o; if not missing(actual) and abs(actual-(8.52516136106541))<=1e-10*max(1,abs(8.52516136106541)) then put 'ROUND10_PASS=K4206';
else put 'ERROR: ROUND10_FAIL=K4206 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4206:; quit;
