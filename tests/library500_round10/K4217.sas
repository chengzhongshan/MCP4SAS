/* K4217 beta_integer_symmetry, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4217o; actual=beta(8,8); run;

data _null_; if 0 then set k4217o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4217 rows=' rows;
else do; set k4217o; if not missing(actual) and abs(actual-(1.94250194250194e-05))<=1e-10*max(1,abs(1.94250194250194e-05)) then put 'ROUND10_PASS=K4217';
else put 'ERROR: ROUND10_FAIL=K4217 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4217:; quit;
