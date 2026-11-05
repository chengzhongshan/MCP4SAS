/* K4175 geometric_zero_failures, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4175o; actual=pdf('geometric',0,1/(6+1)); run;

data _null_; if 0 then set k4175o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4175 rows=' rows;
else do; set k4175o; if not missing(actual) and abs(actual-(0.142857142857143))<=1e-10*max(1,abs(0.142857142857143)) then put 'ROUND10_PASS=K4175';
else put 'ERROR: ROUND10_FAIL=K4175 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4175:; quit;
