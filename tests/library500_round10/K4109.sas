/* K4109 exponential_scale_quantile, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4109o; actual=quantile('exponential',1-exp(-1),10); run;

data _null_; if 0 then set k4109o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4109 rows=' rows;
else do; set k4109o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND10_PASS=K4109';
else put 'ERROR: ROUND10_FAIL=K4109 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4109:; quit;
