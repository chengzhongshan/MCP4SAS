/* J3588 anova_error_ss, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3588a; do grp=1 to 2; do j=1 to 9; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3588b;
proc anova data=j3588a; class grp; model y=grp; run; quit;
ods output close;
data j3588o; set j3588b; if upcase(source)='ERROR'; actual=ss; run;

data _null_; if 0 then set j3588o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3588 rows=' rows;
else do; set j3588o; if not missing(actual) and abs(actual-(120))<=1e-6*max(1,abs(120)) then put 'ROUND8_PASS=J3588';
else put 'ERROR: ROUND8_FAIL=J3588 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3588:; quit;
