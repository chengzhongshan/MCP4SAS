/* K4246 student_t_center_cdf, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4246o; actual=cdf('t',0,7); run;

data _null_; if 0 then set k4246o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4246 rows=' rows;
else do; set k4246o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4246';
else put 'ERROR: ROUND10_FAIL=K4246 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4246:; quit;
