/* K4057 normal_density_location, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4057o; actual=pdf('normal',8,8,2); run;

data _null_; if 0 then set k4057o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4057 rows=' rows;
else do; set k4057o; if not missing(actual) and abs(actual-(0.199471140200716))<=1e-10*max(1,abs(0.199471140200716)) then put 'ROUND10_PASS=K4057';
else put 'ERROR: ROUND10_FAIL=K4057 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4057:; quit;
