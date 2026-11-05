/* K4157 poisson_zero_density, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4157o; actual=pdf('poisson',0,8); run;

data _null_; if 0 then set k4157o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4157 rows=' rows;
else do; set k4157o; if not missing(actual) and abs(actual-(0.000335462627902512))<=1e-10*max(1,abs(0.000335462627902512)) then put 'ROUND10_PASS=K4157';
else put 'ERROR: ROUND10_FAIL=K4157 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4157:; quit;
