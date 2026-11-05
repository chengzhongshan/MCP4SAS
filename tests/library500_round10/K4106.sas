/* K4106 exponential_scale_quantile, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4106o; actual=quantile('exponential',1-exp(-1),7); run;

data _null_; if 0 then set k4106o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4106 rows=' rows;
else do; set k4106o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND10_PASS=K4106';
else put 'ERROR: ROUND10_FAIL=K4106 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4106:; quit;
