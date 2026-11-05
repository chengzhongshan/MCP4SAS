/* K4111 uniform_midpoint_cdf, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4111o; actual=cdf('uniform',2,0,2*2); run;

data _null_; if 0 then set k4111o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4111 rows=' rows;
else do; set k4111o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4111';
else put 'ERROR: ROUND10_FAIL=K4111 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4111:; quit;
