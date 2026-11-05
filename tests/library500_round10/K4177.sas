/* K4177 geometric_zero_failures, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4177o; actual=pdf('geometric',0,1/(8+1)); run;

data _null_; if 0 then set k4177o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4177 rows=' rows;
else do; set k4177o; if not missing(actual) and abs(actual-(0.111111111111111))<=1e-10*max(1,abs(0.111111111111111)) then put 'ROUND10_PASS=K4177';
else put 'ERROR: ROUND10_FAIL=K4177 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4177:; quit;
