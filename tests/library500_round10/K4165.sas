/* K4165 poisson_one_cdf, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4165o; actual=cdf('poisson',1,6); run;

data _null_; if 0 then set k4165o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4165 rows=' rows;
else do; set k4165o; if not missing(actual) and abs(actual-(0.0173512652366645))<=1e-10*max(1,abs(0.0173512652366645)) then put 'ROUND10_PASS=K4165';
else put 'ERROR: ROUND10_FAIL=K4165 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4165:; quit;
