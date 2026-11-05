/* K4211 beta_integer_symmetry, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4211o; actual=beta(2,2); run;

data _null_; if 0 then set k4211o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4211 rows=' rows;
else do; set k4211o; if not missing(actual) and abs(actual-(0.166666666666667))<=1e-10*max(1,abs(0.166666666666667)) then put 'ROUND10_PASS=K4211';
else put 'ERROR: ROUND10_FAIL=K4211 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4211:; quit;
