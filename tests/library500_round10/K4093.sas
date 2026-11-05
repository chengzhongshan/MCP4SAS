/* K4093 exponential_scale_cdf, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4093o; actual=cdf('exponential',4,4); run;

data _null_; if 0 then set k4093o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4093 rows=' rows;
else do; set k4093o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4093';
else put 'ERROR: ROUND10_FAIL=K4093 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4093:; quit;
