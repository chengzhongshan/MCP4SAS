/* K4166 poisson_one_cdf, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4166o; actual=cdf('poisson',1,7); run;

data _null_; if 0 then set k4166o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4166 rows=' rows;
else do; set k4166o; if not missing(actual) and abs(actual-(0.00729505572443613))<=1e-10*max(1,abs(0.00729505572443613)) then put 'ROUND10_PASS=K4166';
else put 'ERROR: ROUND10_FAIL=K4166 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4166:; quit;
