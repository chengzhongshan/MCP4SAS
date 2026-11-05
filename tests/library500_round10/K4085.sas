/* K4085 normal_quantile_location, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4085o; actual=quantile('normal',0.5,6,2); run;

data _null_; if 0 then set k4085o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4085 rows=' rows;
else do; set k4085o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND10_PASS=K4085';
else put 'ERROR: ROUND10_FAIL=K4085 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4085:; quit;
