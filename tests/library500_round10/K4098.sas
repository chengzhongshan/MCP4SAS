/* K4098 exponential_scale_cdf, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4098o; actual=cdf('exponential',9,9); run;

data _null_; if 0 then set k4098o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4098 rows=' rows;
else do; set k4098o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4098';
else put 'ERROR: ROUND10_FAIL=K4098 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4098:; quit;
