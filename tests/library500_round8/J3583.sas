/* J3583 anova_error_ss, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3583a; do grp=1 to 2; do j=1 to 4; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3583b;
proc anova data=j3583a; class grp; model y=grp; run; quit;
ods output close;
data j3583o; set j3583b; if upcase(source)='ERROR'; actual=ss; run;

data _null_; if 0 then set j3583o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3583 rows=' rows;
else do; set j3583o; if not missing(actual) and abs(actual-(10))<=1e-6*max(1,abs(10)) then put 'ROUND8_PASS=J3583';
else put 'ERROR: ROUND8_FAIL=J3583 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3583:; quit;
