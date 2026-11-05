/* K4104 exponential_scale_quantile, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4104o; actual=quantile('exponential',1-exp(-1),5); run;

data _null_; if 0 then set k4104o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4104 rows=' rows;
else do; set k4104o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND10_PASS=K4104';
else put 'ERROR: ROUND10_FAIL=K4104 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4104:; quit;
