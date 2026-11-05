/* K4126 uniform_quartile_location, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4126o; actual=quantile('uniform',0.25,7,5*7); run;

data _null_; if 0 then set k4126o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4126 rows=' rows;
else do; set k4126o; if not missing(actual) and abs(actual-(14))<=1e-10*max(1,abs(14)) then put 'ROUND10_PASS=K4126';
else put 'ERROR: ROUND10_FAIL=K4126 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4126:; quit;
