/* K4150 binomial_one_density, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4150o; actual=pdf('binomial',1,0.25,11); run;

data _null_; if 0 then set k4150o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4150 rows=' rows;
else do; set k4150o; if not missing(actual) and abs(actual-(0.15486216545105))<=1e-10*max(1,abs(0.15486216545105)) then put 'ROUND10_PASS=K4150';
else put 'ERROR: ROUND10_FAIL=K4150 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4150:; quit;
