/* K4245 student_t_center_cdf, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4245o; actual=cdf('t',0,6); run;

data _null_; if 0 then set k4245o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4245 rows=' rows;
else do; set k4245o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4245';
else put 'ERROR: ROUND10_FAIL=K4245 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4245:; quit;
