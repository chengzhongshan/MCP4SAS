/* K4237 weibull_unit_scale_ratio, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4237o; actual=cdf('weibull',8,2,8); run;

data _null_; if 0 then set k4237o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4237 rows=' rows;
else do; set k4237o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4237';
else put 'ERROR: ROUND10_FAIL=K4237 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4237:; quit;
