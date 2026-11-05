/* K4128 uniform_quartile_location, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4128o; actual=quantile('uniform',0.25,9,5*9); run;

data _null_; if 0 then set k4128o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4128 rows=' rows;
else do; set k4128o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND10_PASS=K4128';
else put 'ERROR: ROUND10_FAIL=K4128 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4128:; quit;
