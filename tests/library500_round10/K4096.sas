/* K4096 exponential_scale_cdf, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4096o; actual=cdf('exponential',7,7); run;

data _null_; if 0 then set k4096o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4096 rows=' rows;
else do; set k4096o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4096';
else put 'ERROR: ROUND10_FAIL=K4096 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4096:; quit;
