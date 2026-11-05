/* K4149 binomial_one_density, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4149o; actual=pdf('binomial',1,0.25,10); run;

data _null_; if 0 then set k4149o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4149 rows=' rows;
else do; set k4149o; if not missing(actual) and abs(actual-(0.187711715698242))<=1e-10*max(1,abs(0.187711715698242)) then put 'ROUND10_PASS=K4149';
else put 'ERROR: ROUND10_FAIL=K4149 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4149:; quit;
