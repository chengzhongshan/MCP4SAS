/* K4198 chisquare_two_df_cdf, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4198o; actual=cdf('chisquare',2*9,2); run;

data _null_; if 0 then set k4198o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4198 rows=' rows;
else do; set k4198o; if not missing(actual) and abs(actual-(0.999876590195913))<=1e-10*max(1,abs(0.999876590195913)) then put 'ROUND10_PASS=K4198';
else put 'ERROR: ROUND10_FAIL=K4198 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4198:; quit;
