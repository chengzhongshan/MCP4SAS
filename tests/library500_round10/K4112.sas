/* K4112 uniform_midpoint_cdf, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4112o; actual=cdf('uniform',3,0,2*3); run;

data _null_; if 0 then set k4112o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4112 rows=' rows;
else do; set k4112o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4112';
else put 'ERROR: ROUND10_FAIL=K4112 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4112:; quit;
