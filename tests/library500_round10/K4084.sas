/* K4084 normal_quantile_location, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4084o; actual=quantile('normal',0.5,5,2); run;

data _null_; if 0 then set k4084o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4084 rows=' rows;
else do; set k4084o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND10_PASS=K4084';
else put 'ERROR: ROUND10_FAIL=K4084 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4084:; quit;
