/* K4129 uniform_quartile_location, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4129o; actual=quantile('uniform',0.25,10,5*10); run;

data _null_; if 0 then set k4129o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4129 rows=' rows;
else do; set k4129o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND10_PASS=K4129';
else put 'ERROR: ROUND10_FAIL=K4129 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4129:; quit;
