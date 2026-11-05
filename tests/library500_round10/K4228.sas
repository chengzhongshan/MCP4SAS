/* K4228 logistic_location_cdf, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4228o; actual=cdf('logistic',9,9,2); run;

data _null_; if 0 then set k4228o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4228 rows=' rows;
else do; set k4228o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4228';
else put 'ERROR: ROUND10_FAIL=K4228 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4228:; quit;
