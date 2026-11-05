/* K4079 normal_complement_symmetry, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4079o; actual=cdf('normal',10/10)+cdf('normal',-10/10); run;

data _null_; if 0 then set k4079o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4079 rows=' rows;
else do; set k4079o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND10_PASS=K4079';
else put 'ERROR: ROUND10_FAIL=K4079 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4079:; quit;
