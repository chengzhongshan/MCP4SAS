/* K4105 exponential_scale_quantile, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4105o; actual=quantile('exponential',1-exp(-1),6); run;

data _null_; if 0 then set k4105o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4105 rows=' rows;
else do; set k4105o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND10_PASS=K4105';
else put 'ERROR: ROUND10_FAIL=K4105 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4105:; quit;
