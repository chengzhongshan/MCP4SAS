/* K4125 uniform_quartile_location, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4125o; actual=quantile('uniform',0.25,6,5*6); run;

data _null_; if 0 then set k4125o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4125 rows=' rows;
else do; set k4125o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND10_PASS=K4125';
else put 'ERROR: ROUND10_FAIL=K4125 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4125:; quit;
