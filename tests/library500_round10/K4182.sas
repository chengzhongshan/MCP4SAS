/* K4182 gamma_shape_one_cdf, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4182o; actual=cdf('gamma',3,1,3); run;

data _null_; if 0 then set k4182o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4182 rows=' rows;
else do; set k4182o; if not missing(actual) and abs(actual-(0.632120558828558))<=1e-10*max(1,abs(0.632120558828558)) then put 'ROUND10_PASS=K4182';
else put 'ERROR: ROUND10_FAIL=K4182 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4182:; quit;
