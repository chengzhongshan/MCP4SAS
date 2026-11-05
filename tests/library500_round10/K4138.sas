/* K4138 binomial_zero_cdf, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4138o; actual=cdf('binomial',0,0.25,9); run;

data _null_; if 0 then set k4138o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4138 rows=' rows;
else do; set k4138o; if not missing(actual) and abs(actual-(0.0750846862792969))<=1e-10*max(1,abs(0.0750846862792969)) then put 'ROUND10_PASS=K4138';
else put 'ERROR: ROUND10_FAIL=K4138 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4138:; quit;
