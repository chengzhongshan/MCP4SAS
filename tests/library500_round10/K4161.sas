/* K4161 poisson_one_cdf, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4161o; actual=cdf('poisson',1,2); run;

data _null_; if 0 then set k4161o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4161 rows=' rows;
else do; set k4161o; if not missing(actual) and abs(actual-(0.406005849709838))<=1e-10*max(1,abs(0.406005849709838)) then put 'ROUND10_PASS=K4161';
else put 'ERROR: ROUND10_FAIL=K4161 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4161:; quit;
