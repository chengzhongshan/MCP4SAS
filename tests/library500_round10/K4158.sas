/* K4158 poisson_zero_density, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4158o; actual=pdf('poisson',0,9); run;

data _null_; if 0 then set k4158o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4158 rows=' rows;
else do; set k4158o; if not missing(actual) and abs(actual-(0.00012340980408668))<=1e-10*max(1,abs(0.00012340980408668)) then put 'ROUND10_PASS=K4158';
else put 'ERROR: ROUND10_FAIL=K4158 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4158:; quit;
