/* K4120 uniform_midpoint_cdf, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4120o; actual=cdf('uniform',11,0,2*11); run;

data _null_; if 0 then set k4120o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4120 rows=' rows;
else do; set k4120o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4120';
else put 'ERROR: ROUND10_FAIL=K4120 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4120:; quit;
