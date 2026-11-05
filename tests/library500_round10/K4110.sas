/* K4110 exponential_scale_quantile, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4110o; actual=quantile('exponential',1-exp(-1),11); run;

data _null_; if 0 then set k4110o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4110 rows=' rows;
else do; set k4110o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND10_PASS=K4110';
else put 'ERROR: ROUND10_FAIL=K4110 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4110:; quit;
