/* K4071 normal_complement_symmetry, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4071o; actual=cdf('normal',2/10)+cdf('normal',-2/10); run;

data _null_; if 0 then set k4071o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4071 rows=' rows;
else do; set k4071o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND10_PASS=K4071';
else put 'ERROR: ROUND10_FAIL=K4071 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4071:; quit;
