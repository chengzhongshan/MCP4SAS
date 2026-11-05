/* K4083 normal_quantile_location, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4083o; actual=quantile('normal',0.5,4,2); run;

data _null_; if 0 then set k4083o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4083 rows=' rows;
else do; set k4083o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND10_PASS=K4083';
else put 'ERROR: ROUND10_FAIL=K4083 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4083:; quit;
