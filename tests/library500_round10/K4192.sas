/* K4192 chisquare_two_df_cdf, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4192o; actual=cdf('chisquare',2*3,2); run;

data _null_; if 0 then set k4192o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4192 rows=' rows;
else do; set k4192o; if not missing(actual) and abs(actual-(0.950212931632136))<=1e-10*max(1,abs(0.950212931632136)) then put 'ROUND10_PASS=K4192';
else put 'ERROR: ROUND10_FAIL=K4192 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4192:; quit;
