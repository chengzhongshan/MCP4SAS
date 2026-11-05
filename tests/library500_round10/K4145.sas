/* K4145 binomial_one_density, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4145o; actual=pdf('binomial',1,0.25,6); run;

data _null_; if 0 then set k4145o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4145 rows=' rows;
else do; set k4145o; if not missing(actual) and abs(actual-(0.35595703125))<=1e-10*max(1,abs(0.35595703125)) then put 'ROUND10_PASS=K4145';
else put 'ERROR: ROUND10_FAIL=K4145 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4145:; quit;
