/* K4180 geometric_zero_failures, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4180o; actual=pdf('geometric',0,1/(11+1)); run;

data _null_; if 0 then set k4180o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4180 rows=' rows;
else do; set k4180o; if not missing(actual) and abs(actual-(0.0833333333333333))<=1e-10*max(1,abs(0.0833333333333333)) then put 'ROUND10_PASS=K4180';
else put 'ERROR: ROUND10_FAIL=K4180 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4180:; quit;
