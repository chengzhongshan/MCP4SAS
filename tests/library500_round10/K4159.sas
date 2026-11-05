/* K4159 poisson_zero_density, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4159o; actual=pdf('poisson',0,10); run;

data _null_; if 0 then set k4159o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4159 rows=' rows;
else do; set k4159o; if not missing(actual) and abs(actual-(4.53999297624849e-05))<=1e-10*max(1,abs(4.53999297624849e-05)) then put 'ROUND10_PASS=K4159';
else put 'ERROR: ROUND10_FAIL=K4159 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4159:; quit;
