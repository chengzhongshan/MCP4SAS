/* J3600 anova_model_ss, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3600a; do grp=1 to 2; do j=1 to 11; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3600b;
proc anova data=j3600a; class grp; model y=grp; run; quit;
ods output close;
data j3600o; set j3600b; if upcase(source)='MODEL'; actual=ss; run;

data _null_; if 0 then set j3600o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3600 rows=' rows;
else do; set j3600o; if not missing(actual) and abs(actual-(550))<=1e-6*max(1,abs(550)) then put 'ROUND8_PASS=J3600';
else put 'ERROR: ROUND8_FAIL=J3600 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3600:; quit;
