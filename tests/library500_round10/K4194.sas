/* K4194 chisquare_two_df_cdf, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4194o; actual=cdf('chisquare',2*5,2); run;

data _null_; if 0 then set k4194o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4194 rows=' rows;
else do; set k4194o; if not missing(actual) and abs(actual-(0.993262053000915))<=1e-10*max(1,abs(0.993262053000915)) then put 'ROUND10_PASS=K4194';
else put 'ERROR: ROUND10_FAIL=K4194 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4194:; quit;
