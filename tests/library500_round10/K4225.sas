/* K4225 logistic_location_cdf, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4225o; actual=cdf('logistic',6,6,2); run;

data _null_; if 0 then set k4225o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4225 rows=' rows;
else do; set k4225o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4225';
else put 'ERROR: ROUND10_FAIL=K4225 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4225:; quit;
