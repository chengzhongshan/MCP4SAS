/* K4115 uniform_midpoint_cdf, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4115o; actual=cdf('uniform',6,0,2*6); run;

data _null_; if 0 then set k4115o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4115 rows=' rows;
else do; set k4115o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4115';
else put 'ERROR: ROUND10_FAIL=K4115 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4115:; quit;
