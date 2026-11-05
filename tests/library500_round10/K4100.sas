/* K4100 exponential_scale_cdf, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4100o; actual=cdf('exponential',11,11); run;

data _null_; if 0 then set k4100o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4100 rows=' rows;
else do; set k4100o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4100';
else put 'ERROR: ROUND10_FAIL=K4100 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4100:; quit;
