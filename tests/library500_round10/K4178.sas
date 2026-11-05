/* K4178 geometric_zero_failures, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4178o; actual=pdf('geometric',0,1/(9+1)); run;

data _null_; if 0 then set k4178o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4178 rows=' rows;
else do; set k4178o; if not missing(actual) and abs(actual-(0.1))<=1e-10*max(1,abs(0.1)) then put 'ROUND10_PASS=K4178';
else put 'ERROR: ROUND10_FAIL=K4178 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4178:; quit;
