/* K4197 chisquare_two_df_cdf, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4197o; actual=cdf('chisquare',2*8,2); run;

data _null_; if 0 then set k4197o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4197 rows=' rows;
else do; set k4197o; if not missing(actual) and abs(actual-(0.999664537372097))<=1e-10*max(1,abs(0.999664537372097)) then put 'ROUND10_PASS=K4197';
else put 'ERROR: ROUND10_FAIL=K4197 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4197:; quit;
