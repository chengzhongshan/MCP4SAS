/* K4141 binomial_one_density, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4141o; actual=pdf('binomial',1,0.25,2); run;

data _null_; if 0 then set k4141o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4141 rows=' rows;
else do; set k4141o; if not missing(actual) and abs(actual-(0.375))<=1e-10*max(1,abs(0.375)) then put 'ROUND10_PASS=K4141';
else put 'ERROR: ROUND10_FAIL=K4141 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4141:; quit;
