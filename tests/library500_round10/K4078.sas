/* K4078 normal_complement_symmetry, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4078o; actual=cdf('normal',9/10)+cdf('normal',-9/10); run;

data _null_; if 0 then set k4078o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4078 rows=' rows;
else do; set k4078o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND10_PASS=K4078';
else put 'ERROR: ROUND10_FAIL=K4078 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4078:; quit;
