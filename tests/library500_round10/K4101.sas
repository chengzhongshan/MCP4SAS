/* K4101 exponential_scale_quantile, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4101o; actual=quantile('exponential',1-exp(-1),2); run;

data _null_; if 0 then set k4101o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4101 rows=' rows;
else do; set k4101o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND10_PASS=K4101';
else put 'ERROR: ROUND10_FAIL=K4101 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4101:; quit;
