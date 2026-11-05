/* K4199 chisquare_two_df_cdf, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4199o; actual=cdf('chisquare',2*10,2); run;

data _null_; if 0 then set k4199o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4199 rows=' rows;
else do; set k4199o; if not missing(actual) and abs(actual-(0.999954600070238))<=1e-10*max(1,abs(0.999954600070238)) then put 'ROUND10_PASS=K4199';
else put 'ERROR: ROUND10_FAIL=K4199 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4199:; quit;
