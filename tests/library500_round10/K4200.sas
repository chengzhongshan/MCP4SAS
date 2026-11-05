/* K4200 chisquare_two_df_cdf, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4200o; actual=cdf('chisquare',2*11,2); run;

data _null_; if 0 then set k4200o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4200 rows=' rows;
else do; set k4200o; if not missing(actual) and abs(actual-(0.99998329829921))<=1e-10*max(1,abs(0.99998329829921)) then put 'ROUND10_PASS=K4200';
else put 'ERROR: ROUND10_FAIL=K4200 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4200:; quit;
