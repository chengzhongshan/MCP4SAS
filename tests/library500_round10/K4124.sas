/* K4124 uniform_quartile_location, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4124o; actual=quantile('uniform',0.25,5,5*5); run;

data _null_; if 0 then set k4124o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4124 rows=' rows;
else do; set k4124o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND10_PASS=K4124';
else put 'ERROR: ROUND10_FAIL=K4124 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4124:; quit;
