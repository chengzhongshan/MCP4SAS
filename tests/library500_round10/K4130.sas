/* K4130 uniform_quartile_location, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4130o; actual=quantile('uniform',0.25,11,5*11); run;

data _null_; if 0 then set k4130o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4130 rows=' rows;
else do; set k4130o; if not missing(actual) and abs(actual-(22))<=1e-10*max(1,abs(22)) then put 'ROUND10_PASS=K4130';
else put 'ERROR: ROUND10_FAIL=K4130 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4130:; quit;
