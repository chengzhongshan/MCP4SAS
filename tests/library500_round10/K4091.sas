/* K4091 exponential_scale_cdf, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4091o; actual=cdf('exponential',2,2); run;

data _null_; if 0 then set k4091o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4091 rows=' rows;
else do; set k4091o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4091';
else put 'ERROR: ROUND10_FAIL=K4091 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4091:; quit;
