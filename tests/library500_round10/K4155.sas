/* K4155 poisson_zero_density, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4155o; actual=pdf('poisson',0,6); run;

data _null_; if 0 then set k4155o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4155 rows=' rows;
else do; set k4155o; if not missing(actual) and abs(actual-(0.00247875217666636))<=1e-10*max(1,abs(0.00247875217666636)) then put 'ROUND10_PASS=K4155';
else put 'ERROR: ROUND10_FAIL=K4155 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4155:; quit;
