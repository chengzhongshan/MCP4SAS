/* J3591 anova_model_ss, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3591a; do grp=1 to 2; do j=1 to 2; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3591b;
proc anova data=j3591a; class grp; model y=grp; run; quit;
ods output close;
data j3591o; set j3591b; if upcase(source)='MODEL'; actual=ss; run;

data _null_; if 0 then set j3591o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3591 rows=' rows;
else do; set j3591o; if not missing(actual) and abs(actual-(100))<=1e-6*max(1,abs(100)) then put 'ROUND8_PASS=J3591';
else put 'ERROR: ROUND8_FAIL=J3591 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3591:; quit;
