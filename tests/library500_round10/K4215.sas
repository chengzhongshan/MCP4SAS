/* K4215 beta_integer_symmetry, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4215o; actual=beta(6,6); run;

data _null_; if 0 then set k4215o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4215 rows=' rows;
else do; set k4215o; if not missing(actual) and abs(actual-(0.000360750360750361))<=1e-10*max(1,abs(0.000360750360750361)) then put 'ROUND10_PASS=K4215';
else put 'ERROR: ROUND10_FAIL=K4215 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4215:; quit;
