/* K4076 normal_complement_symmetry, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4076o; actual=cdf('normal',7/10)+cdf('normal',-7/10); run;

data _null_; if 0 then set k4076o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4076 rows=' rows;
else do; set k4076o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND10_PASS=K4076';
else put 'ERROR: ROUND10_FAIL=K4076 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4076:; quit;
