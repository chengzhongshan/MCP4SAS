/* K4052 normal_density_location, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4052o; actual=pdf('normal',3,3,2); run;

data _null_; if 0 then set k4052o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4052 rows=' rows;
else do; set k4052o; if not missing(actual) and abs(actual-(0.199471140200716))<=1e-10*max(1,abs(0.199471140200716)) then put 'ROUND10_PASS=K4052';
else put 'ERROR: ROUND10_FAIL=K4052 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4052:; quit;
