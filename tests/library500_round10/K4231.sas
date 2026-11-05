/* K4231 weibull_unit_scale_ratio, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4231o; actual=cdf('weibull',2,2,2); run;

data _null_; if 0 then set k4231o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4231 rows=' rows;
else do; set k4231o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4231';
else put 'ERROR: ROUND10_FAIL=K4231 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4231:; quit;
