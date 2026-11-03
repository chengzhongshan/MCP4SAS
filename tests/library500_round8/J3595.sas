/* J3595 anova_model_ss, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3595a; do grp=1 to 2; do j=1 to 6; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3595b;
proc anova data=j3595a; class grp; model y=grp; run; quit;
ods output close;
data j3595o; set j3595b; if upcase(source)='MODEL'; actual=ss; run;

data _null_; if 0 then set j3595o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3595 rows=' rows;
else do; set j3595o; if not missing(actual) and abs(actual-(300))<=1e-6*max(1,abs(300)) then put 'ROUND8_PASS=J3595';
else put 'ERROR: ROUND8_FAIL=J3595 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3595:; quit;
