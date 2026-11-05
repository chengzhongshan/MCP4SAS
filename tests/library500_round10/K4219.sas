/* K4219 beta_integer_symmetry, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4219o; actual=beta(10,10); run;

data _null_; if 0 then set k4219o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4219 rows=' rows;
else do; set k4219o; if not missing(actual) and abs(actual-(1.0825088224469e-06))<=1e-10*max(1,abs(1.0825088224469e-06)) then put 'ROUND10_PASS=K4219';
else put 'ERROR: ROUND10_FAIL=K4219 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4219:; quit;
