/* K4212 beta_integer_symmetry, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4212o; actual=beta(3,3); run;

data _null_; if 0 then set k4212o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4212 rows=' rows;
else do; set k4212o; if not missing(actual) and abs(actual-(0.0333333333333333))<=1e-10*max(1,abs(0.0333333333333333)) then put 'ROUND10_PASS=K4212';
else put 'ERROR: ROUND10_FAIL=K4212 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4212:; quit;
