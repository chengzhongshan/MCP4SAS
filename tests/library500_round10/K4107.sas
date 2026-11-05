/* K4107 exponential_scale_quantile, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4107o; actual=quantile('exponential',1-exp(-1),8); run;

data _null_; if 0 then set k4107o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4107 rows=' rows;
else do; set k4107o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND10_PASS=K4107';
else put 'ERROR: ROUND10_FAIL=K4107 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4107:; quit;
