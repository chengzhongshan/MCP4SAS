/* K4170 poisson_one_cdf, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4170o; actual=cdf('poisson',1,11); run;

data _null_; if 0 then set k4170o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4170 rows=' rows;
else do; set k4170o; if not missing(actual) and abs(actual-(0.000200420409482948))<=1e-10*max(1,abs(0.000200420409482948)) then put 'ROUND10_PASS=K4170';
else put 'ERROR: ROUND10_FAIL=K4170 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4170:; quit;
