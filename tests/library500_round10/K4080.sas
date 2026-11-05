/* K4080 normal_complement_symmetry, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4080o; actual=cdf('normal',11/10)+cdf('normal',-11/10); run;

data _null_; if 0 then set k4080o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4080 rows=' rows;
else do; set k4080o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND10_PASS=K4080';
else put 'ERROR: ROUND10_FAIL=K4080 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4080:; quit;
