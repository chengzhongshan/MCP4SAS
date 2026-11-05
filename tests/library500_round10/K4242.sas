/* K4242 student_t_center_cdf, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4242o; actual=cdf('t',0,3); run;

data _null_; if 0 then set k4242o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4242 rows=' rows;
else do; set k4242o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4242';
else put 'ERROR: ROUND10_FAIL=K4242 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4242:; quit;
