/* K4099 exponential_scale_cdf, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4099o; actual=cdf('exponential',10,10); run;

data _null_; if 0 then set k4099o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4099 rows=' rows;
else do; set k4099o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4099';
else put 'ERROR: ROUND10_FAIL=K4099 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4099:; quit;
