/* K4074 normal_complement_symmetry, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4074o; actual=cdf('normal',5/10)+cdf('normal',-5/10); run;

data _null_; if 0 then set k4074o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4074 rows=' rows;
else do; set k4074o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND10_PASS=K4074';
else put 'ERROR: ROUND10_FAIL=K4074 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4074:; quit;
