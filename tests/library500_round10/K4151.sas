/* K4151 poisson_zero_density, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4151o; actual=pdf('poisson',0,2); run;

data _null_; if 0 then set k4151o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4151 rows=' rows;
else do; set k4151o; if not missing(actual) and abs(actual-(0.135335283236613))<=1e-10*max(1,abs(0.135335283236613)) then put 'ROUND10_PASS=K4151';
else put 'ERROR: ROUND10_FAIL=K4151 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4151:; quit;
