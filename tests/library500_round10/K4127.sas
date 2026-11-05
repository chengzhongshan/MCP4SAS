/* K4127 uniform_quartile_location, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4127o; actual=quantile('uniform',0.25,8,5*8); run;

data _null_; if 0 then set k4127o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4127 rows=' rows;
else do; set k4127o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND10_PASS=K4127';
else put 'ERROR: ROUND10_FAIL=K4127 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4127:; quit;
