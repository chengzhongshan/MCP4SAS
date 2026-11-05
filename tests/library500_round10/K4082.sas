/* K4082 normal_quantile_location, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4082o; actual=quantile('normal',0.5,3,2); run;

data _null_; if 0 then set k4082o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4082 rows=' rows;
else do; set k4082o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND10_PASS=K4082';
else put 'ERROR: ROUND10_FAIL=K4082 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4082:; quit;
