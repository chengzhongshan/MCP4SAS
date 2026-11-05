/* K4144 binomial_one_density, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4144o; actual=pdf('binomial',1,0.25,5); run;

data _null_; if 0 then set k4144o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4144 rows=' rows;
else do; set k4144o; if not missing(actual) and abs(actual-(0.3955078125))<=1e-10*max(1,abs(0.3955078125)) then put 'ROUND10_PASS=K4144';
else put 'ERROR: ROUND10_FAIL=K4144 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4144:; quit;
