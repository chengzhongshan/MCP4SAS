/* K4244 student_t_center_cdf, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4244o; actual=cdf('t',0,5); run;

data _null_; if 0 then set k4244o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4244 rows=' rows;
else do; set k4244o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4244';
else put 'ERROR: ROUND10_FAIL=K4244 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4244:; quit;
