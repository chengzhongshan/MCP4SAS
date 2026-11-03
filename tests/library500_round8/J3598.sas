/* J3598 anova_model_ss, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3598a; do grp=1 to 2; do j=1 to 9; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3598b;
proc anova data=j3598a; class grp; model y=grp; run; quit;
ods output close;
data j3598o; set j3598b; if upcase(source)='MODEL'; actual=ss; run;

data _null_; if 0 then set j3598o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3598 rows=' rows;
else do; set j3598o; if not missing(actual) and abs(actual-(450))<=1e-6*max(1,abs(450)) then put 'ROUND8_PASS=J3598';
else put 'ERROR: ROUND8_FAIL=J3598 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3598:; quit;
