/* K4097 exponential_scale_cdf, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4097o; actual=cdf('exponential',8,8); run;

data _null_; if 0 then set k4097o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4097 rows=' rows;
else do; set k4097o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4097';
else put 'ERROR: ROUND10_FAIL=K4097 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4097:; quit;
