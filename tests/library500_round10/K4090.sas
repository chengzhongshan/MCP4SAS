/* K4090 normal_quantile_location, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4090o; actual=quantile('normal',0.5,11,2); run;

data _null_; if 0 then set k4090o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4090 rows=' rows;
else do; set k4090o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND10_PASS=K4090';
else put 'ERROR: ROUND10_FAIL=K4090 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4090:; quit;
