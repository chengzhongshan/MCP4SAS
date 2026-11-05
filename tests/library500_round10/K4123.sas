/* K4123 uniform_quartile_location, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4123o; actual=quantile('uniform',0.25,4,5*4); run;

data _null_; if 0 then set k4123o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4123 rows=' rows;
else do; set k4123o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND10_PASS=K4123';
else put 'ERROR: ROUND10_FAIL=K4123 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4123:; quit;
