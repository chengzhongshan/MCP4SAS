/* K4164 poisson_one_cdf, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4164o; actual=cdf('poisson',1,5); run;

data _null_; if 0 then set k4164o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4164 rows=' rows;
else do; set k4164o; if not missing(actual) and abs(actual-(0.0404276819945128))<=1e-10*max(1,abs(0.0404276819945128)) then put 'ROUND10_PASS=K4164';
else put 'ERROR: ROUND10_FAIL=K4164 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4164:; quit;
