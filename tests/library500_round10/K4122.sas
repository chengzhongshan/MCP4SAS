/* K4122 uniform_quartile_location, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4122o; actual=quantile('uniform',0.25,3,5*3); run;

data _null_; if 0 then set k4122o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4122 rows=' rows;
else do; set k4122o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND10_PASS=K4122';
else put 'ERROR: ROUND10_FAIL=K4122 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4122:; quit;
