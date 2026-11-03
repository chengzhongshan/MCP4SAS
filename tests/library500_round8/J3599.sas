/* J3599 anova_model_ss, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3599a; do grp=1 to 2; do j=1 to 10; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3599b;
proc anova data=j3599a; class grp; model y=grp; run; quit;
ods output close;
data j3599o; set j3599b; if upcase(source)='MODEL'; actual=ss; run;

data _null_; if 0 then set j3599o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3599 rows=' rows;
else do; set j3599o; if not missing(actual) and abs(actual-(500))<=1e-6*max(1,abs(500)) then put 'ROUND8_PASS=J3599';
else put 'ERROR: ROUND8_FAIL=J3599 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3599:; quit;
