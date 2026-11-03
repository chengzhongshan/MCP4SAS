/* J3596 anova_model_ss, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3596a; do grp=1 to 2; do j=1 to 7; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3596b;
proc anova data=j3596a; class grp; model y=grp; run; quit;
ods output close;
data j3596o; set j3596b; if upcase(source)='MODEL'; actual=ss; run;

data _null_; if 0 then set j3596o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3596 rows=' rows;
else do; set j3596o; if not missing(actual) and abs(actual-(350))<=1e-6*max(1,abs(350)) then put 'ROUND8_PASS=J3596';
else put 'ERROR: ROUND8_FAIL=J3596 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3596:; quit;
