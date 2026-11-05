/* K4153 poisson_zero_density, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4153o; actual=pdf('poisson',0,4); run;

data _null_; if 0 then set k4153o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4153 rows=' rows;
else do; set k4153o; if not missing(actual) and abs(actual-(0.0183156388887342))<=1e-10*max(1,abs(0.0183156388887342)) then put 'ROUND10_PASS=K4153';
else put 'ERROR: ROUND10_FAIL=K4153 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4153:; quit;
