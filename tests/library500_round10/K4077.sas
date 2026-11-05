/* K4077 normal_complement_symmetry, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4077o; actual=cdf('normal',8/10)+cdf('normal',-8/10); run;

data _null_; if 0 then set k4077o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4077 rows=' rows;
else do; set k4077o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND10_PASS=K4077';
else put 'ERROR: ROUND10_FAIL=K4077 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4077:; quit;
