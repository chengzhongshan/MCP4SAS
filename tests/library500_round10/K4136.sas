/* K4136 binomial_zero_cdf, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4136o; actual=cdf('binomial',0,0.25,7); run;

data _null_; if 0 then set k4136o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4136 rows=' rows;
else do; set k4136o; if not missing(actual) and abs(actual-(0.13348388671875))<=1e-10*max(1,abs(0.13348388671875)) then put 'ROUND10_PASS=K4136';
else put 'ERROR: ROUND10_FAIL=K4136 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4136:; quit;
