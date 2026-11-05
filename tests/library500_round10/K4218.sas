/* K4218 beta_integer_symmetry, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4218o; actual=beta(9,9); run;

data _null_; if 0 then set k4218o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4218 rows=' rows;
else do; set k4218o; if not missing(actual) and abs(actual-(4.57059280588692e-06))<=1e-10*max(1,abs(4.57059280588692e-06)) then put 'ROUND10_PASS=K4218';
else put 'ERROR: ROUND10_FAIL=K4218 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4218:; quit;
