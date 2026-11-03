/* J3589 anova_error_ss, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3589a; do grp=1 to 2; do j=1 to 10; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3589b;
proc anova data=j3589a; class grp; model y=grp; run; quit;
ods output close;
data j3589o; set j3589b; if upcase(source)='ERROR'; actual=ss; run;

data _null_; if 0 then set j3589o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3589 rows=' rows;
else do; set j3589o; if not missing(actual) and abs(actual-(165))<=1e-6*max(1,abs(165)) then put 'ROUND8_PASS=J3589';
else put 'ERROR: ROUND8_FAIL=J3589 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3589:; quit;
