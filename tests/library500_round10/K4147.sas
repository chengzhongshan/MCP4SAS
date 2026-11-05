/* K4147 binomial_one_density, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4147o; actual=pdf('binomial',1,0.25,8); run;

data _null_; if 0 then set k4147o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4147 rows=' rows;
else do; set k4147o; if not missing(actual) and abs(actual-(0.2669677734375))<=1e-10*max(1,abs(0.2669677734375)) then put 'ROUND10_PASS=K4147';
else put 'ERROR: ROUND10_FAIL=K4147 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4147:; quit;
