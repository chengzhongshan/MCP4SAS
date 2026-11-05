/* K4137 binomial_zero_cdf, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4137o; actual=cdf('binomial',0,0.25,8); run;

data _null_; if 0 then set k4137o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4137 rows=' rows;
else do; set k4137o; if not missing(actual) and abs(actual-(0.100112915039062))<=1e-10*max(1,abs(0.100112915039062)) then put 'ROUND10_PASS=K4137';
else put 'ERROR: ROUND10_FAIL=K4137 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4137:; quit;
