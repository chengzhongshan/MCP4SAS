/* K4240 weibull_unit_scale_ratio, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4240o; actual=cdf('weibull',11,2,11); run;

data _null_; if 0 then set k4240o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4240 rows=' rows;
else do; set k4240o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4240';
else put 'ERROR: ROUND10_FAIL=K4240 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4240:; quit;
