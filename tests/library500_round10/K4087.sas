/* K4087 normal_quantile_location, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4087o; actual=quantile('normal',0.5,8,2); run;

data _null_; if 0 then set k4087o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4087 rows=' rows;
else do; set k4087o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND10_PASS=K4087';
else put 'ERROR: ROUND10_FAIL=K4087 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4087:; quit;
