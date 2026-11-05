/* K4226 logistic_location_cdf, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4226o; actual=cdf('logistic',7,7,2); run;

data _null_; if 0 then set k4226o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4226 rows=' rows;
else do; set k4226o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4226';
else put 'ERROR: ROUND10_FAIL=K4226 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4226:; quit;
