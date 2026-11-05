/* K4061 normal_cdf_location, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4061o; actual=cdf('normal',2,2,3); run;

data _null_; if 0 then set k4061o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4061 rows=' rows;
else do; set k4061o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4061';
else put 'ERROR: ROUND10_FAIL=K4061 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4061:; quit;
