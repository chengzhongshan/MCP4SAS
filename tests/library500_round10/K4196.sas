/* K4196 chisquare_two_df_cdf, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4196o; actual=cdf('chisquare',2*7,2); run;

data _null_; if 0 then set k4196o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4196 rows=' rows;
else do; set k4196o; if not missing(actual) and abs(actual-(0.999088118034446))<=1e-10*max(1,abs(0.999088118034446)) then put 'ROUND10_PASS=K4196';
else put 'ERROR: ROUND10_FAIL=K4196 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4196:; quit;
