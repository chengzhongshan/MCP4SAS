/* K4160 poisson_zero_density, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4160o; actual=pdf('poisson',0,11); run;

data _null_; if 0 then set k4160o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4160 rows=' rows;
else do; set k4160o; if not missing(actual) and abs(actual-(1.67017007902457e-05))<=1e-10*max(1,abs(1.67017007902457e-05)) then put 'ROUND10_PASS=K4160';
else put 'ERROR: ROUND10_FAIL=K4160 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4160:; quit;
