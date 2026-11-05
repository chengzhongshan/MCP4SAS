/* K4148 binomial_one_density, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4148o; actual=pdf('binomial',1,0.25,9); run;

data _null_; if 0 then set k4148o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4148 rows=' rows;
else do; set k4148o; if not missing(actual) and abs(actual-(0.225254058837891))<=1e-10*max(1,abs(0.225254058837891)) then put 'ROUND10_PASS=K4148';
else put 'ERROR: ROUND10_FAIL=K4148 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4148:; quit;
