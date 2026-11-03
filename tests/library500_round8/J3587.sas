/* J3587 anova_error_ss, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3587a; do grp=1 to 2; do j=1 to 8; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3587b;
proc anova data=j3587a; class grp; model y=grp; run; quit;
ods output close;
data j3587o; set j3587b; if upcase(source)='ERROR'; actual=ss; run;

data _null_; if 0 then set j3587o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3587 rows=' rows;
else do; set j3587o; if not missing(actual) and abs(actual-(84))<=1e-6*max(1,abs(84)) then put 'ROUND8_PASS=J3587';
else put 'ERROR: ROUND8_FAIL=J3587 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3587:; quit;
