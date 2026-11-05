/* K4213 beta_integer_symmetry, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4213o; actual=beta(4,4); run;

data _null_; if 0 then set k4213o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4213 rows=' rows;
else do; set k4213o; if not missing(actual) and abs(actual-(0.00714285714285714))<=1e-10*max(1,abs(0.00714285714285714)) then put 'ROUND10_PASS=K4213';
else put 'ERROR: ROUND10_FAIL=K4213 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4213:; quit;
