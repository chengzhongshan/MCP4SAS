/* K4088 normal_quantile_location, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4088o; actual=quantile('normal',0.5,9,2); run;

data _null_; if 0 then set k4088o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4088 rows=' rows;
else do; set k4088o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND10_PASS=K4088';
else put 'ERROR: ROUND10_FAIL=K4088 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4088:; quit;
