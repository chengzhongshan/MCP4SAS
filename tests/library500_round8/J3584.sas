/* J3584 anova_error_ss, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3584a; do grp=1 to 2; do j=1 to 5; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3584b;
proc anova data=j3584a; class grp; model y=grp; run; quit;
ods output close;
data j3584o; set j3584b; if upcase(source)='ERROR'; actual=ss; run;

data _null_; if 0 then set j3584o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3584 rows=' rows;
else do; set j3584o; if not missing(actual) and abs(actual-(20))<=1e-6*max(1,abs(20)) then put 'ROUND8_PASS=J3584';
else put 'ERROR: ROUND8_FAIL=J3584 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3584:; quit;
