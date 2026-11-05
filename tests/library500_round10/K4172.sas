/* K4172 geometric_zero_failures, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4172o; actual=pdf('geometric',0,1/(3+1)); run;

data _null_; if 0 then set k4172o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4172 rows=' rows;
else do; set k4172o; if not missing(actual) and abs(actual-(0.25))<=1e-10*max(1,abs(0.25)) then put 'ROUND10_PASS=K4172';
else put 'ERROR: ROUND10_FAIL=K4172 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4172:; quit;
