/* K4210 log_gamma_integer_factorial, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4210o; actual=lgamma(11+1); run;

data _null_; if 0 then set k4210o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4210 rows=' rows;
else do; set k4210o; if not missing(actual) and abs(actual-(17.5023078458739))<=1e-10*max(1,abs(17.5023078458739)) then put 'ROUND10_PASS=K4210';
else put 'ERROR: ROUND10_FAIL=K4210 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4210:; quit;
