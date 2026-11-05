/* K4187 gamma_shape_one_cdf, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4187o; actual=cdf('gamma',8,1,8); run;

data _null_; if 0 then set k4187o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4187 rows=' rows;
else do; set k4187o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4187';
else put 'ERROR: ROUND10_FAIL=K4187 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4187:; quit;
