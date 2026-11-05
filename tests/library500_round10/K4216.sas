/* K4216 beta_integer_symmetry, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4216o; actual=beta(7,7); run;

data _null_; if 0 then set k4216o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4216 rows=' rows;
else do; set k4216o; if not missing(actual) and abs(actual-(8.32500832500833e-05))<=1e-10*max(1,abs(8.32500832500833e-05)) then put 'ROUND10_PASS=K4216';
else put 'ERROR: ROUND10_FAIL=K4216 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4216:; quit;
