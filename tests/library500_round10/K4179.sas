/* K4179 geometric_zero_failures, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4179o; actual=pdf('geometric',0,1/(10+1)); run;

data _null_; if 0 then set k4179o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4179 rows=' rows;
else do; set k4179o; if not missing(actual) and abs(actual-(0.0909090909090909))<=1e-10*max(1,abs(0.0909090909090909)) then put 'ROUND10_PASS=K4179';
else put 'ERROR: ROUND10_FAIL=K4179 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4179:; quit;
