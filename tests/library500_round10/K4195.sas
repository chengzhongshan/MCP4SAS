/* K4195 chisquare_two_df_cdf, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4195o; actual=cdf('chisquare',2*6,2); run;

data _null_; if 0 then set k4195o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4195 rows=' rows;
else do; set k4195o; if not missing(actual) and abs(actual-(0.997521247823334))<=1e-10*max(1,abs(0.997521247823334)) then put 'ROUND10_PASS=K4195';
else put 'ERROR: ROUND10_FAIL=K4195 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4195:; quit;
