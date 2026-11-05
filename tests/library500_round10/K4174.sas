/* K4174 geometric_zero_failures, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4174o; actual=pdf('geometric',0,1/(5+1)); run;

data _null_; if 0 then set k4174o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4174 rows=' rows;
else do; set k4174o; if not missing(actual) and abs(actual-(0.166666666666667))<=1e-10*max(1,abs(0.166666666666667)) then put 'ROUND10_PASS=K4174';
else put 'ERROR: ROUND10_FAIL=K4174 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4174:; quit;
