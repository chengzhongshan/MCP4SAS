/* K4081 normal_quantile_location, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4081o; actual=quantile('normal',0.5,2,2); run;

data _null_; if 0 then set k4081o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4081 rows=' rows;
else do; set k4081o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND10_PASS=K4081';
else put 'ERROR: ROUND10_FAIL=K4081 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4081:; quit;
