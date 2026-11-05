/* K4156 poisson_zero_density, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4156o; actual=pdf('poisson',0,7); run;

data _null_; if 0 then set k4156o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4156 rows=' rows;
else do; set k4156o; if not missing(actual) and abs(actual-(0.000911881965554516))<=1e-10*max(1,abs(0.000911881965554516)) then put 'ROUND10_PASS=K4156';
else put 'ERROR: ROUND10_FAIL=K4156 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4156:; quit;
