/* K4140 binomial_zero_cdf, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4140o; actual=cdf('binomial',0,0.25,11); run;

data _null_; if 0 then set k4140o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4140 rows=' rows;
else do; set k4140o; if not missing(actual) and abs(actual-(0.0422351360321045))<=1e-10*max(1,abs(0.0422351360321045)) then put 'ROUND10_PASS=K4140';
else put 'ERROR: ROUND10_FAIL=K4140 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4140:; quit;
