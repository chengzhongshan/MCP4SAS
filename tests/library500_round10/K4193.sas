/* K4193 chisquare_two_df_cdf, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4193o; actual=cdf('chisquare',2*4,2); run;

data _null_; if 0 then set k4193o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4193 rows=' rows;
else do; set k4193o; if not missing(actual) and abs(actual-(0.981684361111266))<=1e-10*max(1,abs(0.981684361111266)) then put 'ROUND10_PASS=K4193';
else put 'ERROR: ROUND10_FAIL=K4193 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4193:; quit;
