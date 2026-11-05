/* K4189 gamma_shape_one_cdf, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4189o; actual=cdf('gamma',10,1,10); run;

data _null_; if 0 then set k4189o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4189 rows=' rows;
else do; set k4189o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4189';
else put 'ERROR: ROUND10_FAIL=K4189 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4189:; quit;
