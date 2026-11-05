/* K4131 binomial_zero_cdf, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4131o; actual=cdf('binomial',0,0.25,2); run;

data _null_; if 0 then set k4131o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4131 rows=' rows;
else do; set k4131o; if not missing(actual) and abs(actual-(0.5625))<=1e-10*max(1,abs(0.5625)) then put 'ROUND10_PASS=K4131';
else put 'ERROR: ROUND10_FAIL=K4131 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4131:; quit;
