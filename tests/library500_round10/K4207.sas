/* K4207 log_gamma_integer_factorial, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4207o; actual=lgamma(8+1); run;

data _null_; if 0 then set k4207o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4207 rows=' rows;
else do; set k4207o; if not missing(actual) and abs(actual-(10.6046029027453))<=1e-10*max(1,abs(10.6046029027453)) then put 'ROUND10_PASS=K4207';
else put 'ERROR: ROUND10_FAIL=K4207 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4207:; quit;
