/* K4092 exponential_scale_cdf, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4092o; actual=cdf('exponential',3,3); run;

data _null_; if 0 then set k4092o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4092 rows=' rows;
else do; set k4092o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4092';
else put 'ERROR: ROUND10_FAIL=K4092 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4092:; quit;
