/* K4118 uniform_midpoint_cdf, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4118o; actual=cdf('uniform',9,0,2*9); run;

data _null_; if 0 then set k4118o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4118 rows=' rows;
else do; set k4118o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4118';
else put 'ERROR: ROUND10_FAIL=K4118 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4118:; quit;
