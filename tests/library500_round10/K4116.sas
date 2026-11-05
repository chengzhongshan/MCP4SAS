/* K4116 uniform_midpoint_cdf, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4116o; actual=cdf('uniform',7,0,2*7); run;

data _null_; if 0 then set k4116o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4116 rows=' rows;
else do; set k4116o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4116';
else put 'ERROR: ROUND10_FAIL=K4116 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4116:; quit;
