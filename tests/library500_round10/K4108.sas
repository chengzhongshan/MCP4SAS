/* K4108 exponential_scale_quantile, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4108o; actual=quantile('exponential',1-exp(-1),9); run;

data _null_; if 0 then set k4108o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4108 rows=' rows;
else do; set k4108o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND10_PASS=K4108';
else put 'ERROR: ROUND10_FAIL=K4108 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4108:; quit;
