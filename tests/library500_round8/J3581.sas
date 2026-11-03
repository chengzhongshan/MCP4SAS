/* J3581 anova_error_ss, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3581a; do grp=1 to 2; do j=1 to 2; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3581b;
proc anova data=j3581a; class grp; model y=grp; run; quit;
ods output close;
data j3581o; set j3581b; if upcase(source)='ERROR'; actual=ss; run;

data _null_; if 0 then set j3581o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3581 rows=' rows;
else do; set j3581o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3581';
else put 'ERROR: ROUND8_FAIL=J3581 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3581:; quit;
