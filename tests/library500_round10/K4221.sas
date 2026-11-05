/* K4221 logistic_location_cdf, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4221o; actual=cdf('logistic',2,2,2); run;

data _null_; if 0 then set k4221o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4221 rows=' rows;
else do; set k4221o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4221';
else put 'ERROR: ROUND10_FAIL=K4221 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4221:; quit;
