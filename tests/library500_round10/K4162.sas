/* K4162 poisson_one_cdf, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4162o; actual=cdf('poisson',1,3); run;

data _null_; if 0 then set k4162o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4162 rows=' rows;
else do; set k4162o; if not missing(actual) and abs(actual-(0.199148273471456))<=1e-10*max(1,abs(0.199148273471456)) then put 'ROUND10_PASS=K4162';
else put 'ERROR: ROUND10_FAIL=K4162 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4162:; quit;
