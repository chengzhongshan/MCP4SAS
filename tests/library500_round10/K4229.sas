/* K4229 logistic_location_cdf, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4229o; actual=cdf('logistic',10,10,2); run;

data _null_; if 0 then set k4229o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4229 rows=' rows;
else do; set k4229o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4229';
else put 'ERROR: ROUND10_FAIL=K4229 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4229:; quit;
