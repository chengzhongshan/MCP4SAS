/* K4089 normal_quantile_location, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4089o; actual=quantile('normal',0.5,10,2); run;

data _null_; if 0 then set k4089o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4089 rows=' rows;
else do; set k4089o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND10_PASS=K4089';
else put 'ERROR: ROUND10_FAIL=K4089 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4089:; quit;
