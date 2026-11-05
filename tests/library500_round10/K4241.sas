/* K4241 student_t_center_cdf, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4241o; actual=cdf('t',0,2); run;

data _null_; if 0 then set k4241o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4241 rows=' rows;
else do; set k4241o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4241';
else put 'ERROR: ROUND10_FAIL=K4241 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4241:; quit;
