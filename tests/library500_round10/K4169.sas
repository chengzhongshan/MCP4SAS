/* K4169 poisson_one_cdf, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4169o; actual=cdf('poisson',1,10); run;

data _null_; if 0 then set k4169o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4169 rows=' rows;
else do; set k4169o; if not missing(actual) and abs(actual-(0.000499399227387333))<=1e-10*max(1,abs(0.000499399227387333)) then put 'ROUND10_PASS=K4169';
else put 'ERROR: ROUND10_FAIL=K4169 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4169:; quit;
