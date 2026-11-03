/* J3582 anova_error_ss, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3582a; do grp=1 to 2; do j=1 to 3; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3582b;
proc anova data=j3582a; class grp; model y=grp; run; quit;
ods output close;
data j3582o; set j3582b; if upcase(source)='ERROR'; actual=ss; run;

data _null_; if 0 then set j3582o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3582 rows=' rows;
else do; set j3582o; if not missing(actual) and abs(actual-(4))<=1e-6*max(1,abs(4)) then put 'ROUND8_PASS=J3582';
else put 'ERROR: ROUND8_FAIL=J3582 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3582:; quit;
