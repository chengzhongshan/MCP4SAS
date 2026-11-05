/* K4236 weibull_unit_scale_ratio, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4236o; actual=cdf('weibull',7,2,7); run;

data _null_; if 0 then set k4236o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4236 rows=' rows;
else do; set k4236o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4236';
else put 'ERROR: ROUND10_FAIL=K4236 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4236:; quit;
