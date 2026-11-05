/* K4163 poisson_one_cdf, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4163o; actual=cdf('poisson',1,4); run;

data _null_; if 0 then set k4163o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4163 rows=' rows;
else do; set k4163o; if not missing(actual) and abs(actual-(0.0915781944436709))<=1e-10*max(1,abs(0.0915781944436709)) then put 'ROUND10_PASS=K4163';
else put 'ERROR: ROUND10_FAIL=K4163 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4163:; quit;
