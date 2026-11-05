/* K4146 binomial_one_density, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4146o; actual=pdf('binomial',1,0.25,7); run;

data _null_; if 0 then set k4146o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4146 rows=' rows;
else do; set k4146o; if not missing(actual) and abs(actual-(0.31146240234375))<=1e-10*max(1,abs(0.31146240234375)) then put 'ROUND10_PASS=K4146';
else put 'ERROR: ROUND10_FAIL=K4146 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4146:; quit;
