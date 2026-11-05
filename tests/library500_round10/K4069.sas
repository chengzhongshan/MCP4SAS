/* K4069 normal_cdf_location, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4069o; actual=cdf('normal',10,10,3); run;

data _null_; if 0 then set k4069o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4069 rows=' rows;
else do; set k4069o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4069';
else put 'ERROR: ROUND10_FAIL=K4069 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4069:; quit;
