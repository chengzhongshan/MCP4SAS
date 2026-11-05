/* K4173 geometric_zero_failures, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4173o; actual=pdf('geometric',0,1/(4+1)); run;

data _null_; if 0 then set k4173o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4173 rows=' rows;
else do; set k4173o; if not missing(actual) and abs(actual-(0.2))<=1e-10*max(1,abs(0.2)) then put 'ROUND10_PASS=K4173';
else put 'ERROR: ROUND10_FAIL=K4173 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4173:; quit;
