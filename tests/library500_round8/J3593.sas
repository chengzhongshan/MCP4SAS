/* J3593 anova_model_ss, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3593a; do grp=1 to 2; do j=1 to 4; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3593b;
proc anova data=j3593a; class grp; model y=grp; run; quit;
ods output close;
data j3593o; set j3593b; if upcase(source)='MODEL'; actual=ss; run;

data _null_; if 0 then set j3593o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3593 rows=' rows;
else do; set j3593o; if not missing(actual) and abs(actual-(200))<=1e-6*max(1,abs(200)) then put 'ROUND8_PASS=J3593';
else put 'ERROR: ROUND8_FAIL=J3593 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3593:; quit;
