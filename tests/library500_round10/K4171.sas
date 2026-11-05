/* K4171 geometric_zero_failures, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4171o; actual=pdf('geometric',0,1/(2+1)); run;

data _null_; if 0 then set k4171o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4171 rows=' rows;
else do; set k4171o; if not missing(actual) and abs(actual-(0.333333333333333))<=1e-10*max(1,abs(0.333333333333333)) then put 'ROUND10_PASS=K4171';
else put 'ERROR: ROUND10_FAIL=K4171 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4171:; quit;
