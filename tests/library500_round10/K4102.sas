/* K4102 exponential_scale_quantile, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4102o; actual=quantile('exponential',1-exp(-1),3); run;

data _null_; if 0 then set k4102o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4102 rows=' rows;
else do; set k4102o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND10_PASS=K4102';
else put 'ERROR: ROUND10_FAIL=K4102 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4102:; quit;
