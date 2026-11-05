/* K4167 poisson_one_cdf, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4167o; actual=cdf('poisson',1,8); run;

data _null_; if 0 then set k4167o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4167 rows=' rows;
else do; set k4167o; if not missing(actual) and abs(actual-(0.00301916365112261))<=1e-10*max(1,abs(0.00301916365112261)) then put 'ROUND10_PASS=K4167';
else put 'ERROR: ROUND10_FAIL=K4167 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4167:; quit;
