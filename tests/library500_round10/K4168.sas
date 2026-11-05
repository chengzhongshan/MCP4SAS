/* K4168 poisson_one_cdf, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4168o; actual=cdf('poisson',1,9); run;

data _null_; if 0 then set k4168o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4168 rows=' rows;
else do; set k4168o; if not missing(actual) and abs(actual-(0.0012340980408668))<=1e-10*max(1,abs(0.0012340980408668)) then put 'ROUND10_PASS=K4168';
else put 'ERROR: ROUND10_FAIL=K4168 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4168:; quit;
