/* K4113 uniform_midpoint_cdf, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4113o; actual=cdf('uniform',4,0,2*4); run;

data _null_; if 0 then set k4113o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4113 rows=' rows;
else do; set k4113o; if not missing(actual) and abs(actual-(0.5))<=1e-10*max(1,abs(0.5)) then put 'ROUND10_PASS=K4113';
else put 'ERROR: ROUND10_FAIL=K4113 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4113:; quit;
