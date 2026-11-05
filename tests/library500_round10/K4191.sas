/* K4191 chisquare_two_df_cdf, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:1220 */
data k4191o; actual=cdf('chisquare',2*2,2); run;

data _null_; if 0 then set k4191o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4191 rows=' rows;
else do; set k4191o; if not missing(actual) and abs(actual-(0.864664716763387))<=1e-10*max(1,abs(0.864664716763387)) then put 'ROUND10_PASS=K4191';
else put 'ERROR: ROUND10_FAIL=K4191 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4191:; quit;
