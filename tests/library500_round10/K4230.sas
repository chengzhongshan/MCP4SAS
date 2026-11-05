/* K4230 logistic_location_cdf, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4230o; actual=cdf('logistic',11,11,2); run;

data _null_; if 0 then set k4230o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4230 rows=' rows;
else do; set k4230o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4230';
else put 'ERROR: ROUND10_FAIL=K4230 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4230:; quit;
