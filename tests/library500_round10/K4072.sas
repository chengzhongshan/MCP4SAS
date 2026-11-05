/* K4072 normal_complement_symmetry, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4072o; actual=cdf('normal',3/10)+cdf('normal',-3/10); run;

data _null_; if 0 then set k4072o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4072 rows=' rows;
else do; set k4072o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND10_PASS=K4072';
else put 'ERROR: ROUND10_FAIL=K4072 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4072:; quit;
