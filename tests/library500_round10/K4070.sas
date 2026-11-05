/* K4070 normal_cdf_location, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4070o; actual=cdf('normal',11,11,3); run;

data _null_; if 0 then set k4070o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4070 rows=' rows;
else do; set k4070o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4070';
else put 'ERROR: ROUND10_FAIL=K4070 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4070:; quit;
