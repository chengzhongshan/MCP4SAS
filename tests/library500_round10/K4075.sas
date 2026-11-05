/* K4075 normal_complement_symmetry, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4075o; actual=cdf('normal',6/10)+cdf('normal',-6/10); run;

data _null_; if 0 then set k4075o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4075 rows=' rows;
else do; set k4075o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND10_PASS=K4075';
else put 'ERROR: ROUND10_FAIL=K4075 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4075:; quit;
