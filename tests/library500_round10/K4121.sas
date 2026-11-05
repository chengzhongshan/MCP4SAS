/* K4121 uniform_quartile_location, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4121o; actual=quantile('uniform',0.25,2,5*2); run;

data _null_; if 0 then set k4121o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4121 rows=' rows;
else do; set k4121o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND10_PASS=K4121';
else put 'ERROR: ROUND10_FAIL=K4121 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4121:; quit;
