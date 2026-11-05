/* K4114 uniform_midpoint_cdf, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4114o; actual=cdf('uniform',5,0,2*5); run;

data _null_; if 0 then set k4114o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4114 rows=' rows;
else do; set k4114o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4114';
else put 'ERROR: ROUND10_FAIL=K4114 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4114:; quit;
