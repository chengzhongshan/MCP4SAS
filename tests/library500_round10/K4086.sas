/* K4086 normal_quantile_location, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4086o; actual=quantile('normal',0.5,7,2); run;

data _null_; if 0 then set k4086o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4086 rows=' rows;
else do; set k4086o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND10_PASS=K4086';
else put 'ERROR: ROUND10_FAIL=K4086 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4086:; quit;
