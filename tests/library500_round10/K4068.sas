/* K4068 normal_cdf_location, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4068o; actual=cdf('normal',9,9,3); run;

data _null_; if 0 then set k4068o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4068 rows=' rows;
else do; set k4068o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4068';
else put 'ERROR: ROUND10_FAIL=K4068 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4068:; quit;
