/* K4134 binomial_zero_cdf, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4134o; actual=cdf('binomial',0,0.25,5); run;

data _null_; if 0 then set k4134o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4134 rows=' rows;
else do; set k4134o; if not missing(actual) and abs(actual-(0.2373046875))<=1e-10*max(1,abs(0.2373046875)) then put 'ROUND10_PASS=K4134';
else put 'ERROR: ROUND10_FAIL=K4134 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4134:; quit;
