/* K4103 exponential_scale_quantile, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4103o; actual=quantile('exponential',1-exp(-1),4); run;

data _null_; if 0 then set k4103o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4103 rows=' rows;
else do; set k4103o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND10_PASS=K4103';
else put 'ERROR: ROUND10_FAIL=K4103 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4103:; quit;
