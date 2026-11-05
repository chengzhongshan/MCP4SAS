/* K4119 uniform_midpoint_cdf, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4119o; actual=cdf('uniform',10,0,2*10); run;

data _null_; if 0 then set k4119o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4119 rows=' rows;
else do; set k4119o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4119';
else put 'ERROR: ROUND10_FAIL=K4119 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4119:; quit;
