/* K4073 normal_complement_symmetry, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4073o; actual=cdf('normal',4/10)+cdf('normal',-4/10); run;

data _null_; if 0 then set k4073o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4073 rows=' rows;
else do; set k4073o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND10_PASS=K4073';
else put 'ERROR: ROUND10_FAIL=K4073 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4073:; quit;
