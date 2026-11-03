/* J3594 anova_model_ss, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3594a; do grp=1 to 2; do j=1 to 5; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3594b;
proc anova data=j3594a; class grp; model y=grp; run; quit;
ods output close;
data j3594o; set j3594b; if upcase(source)='MODEL'; actual=ss; run;

data _null_; if 0 then set j3594o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3594 rows=' rows;
else do; set j3594o; if not missing(actual) and abs(actual-(250))<=1e-6*max(1,abs(250)) then put 'ROUND8_PASS=J3594';
else put 'ERROR: ROUND8_FAIL=J3594 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3594:; quit;
