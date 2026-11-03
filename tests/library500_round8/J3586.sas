/* J3586 anova_error_ss, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3586a; do grp=1 to 2; do j=1 to 7; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3586b;
proc anova data=j3586a; class grp; model y=grp; run; quit;
ods output close;
data j3586o; set j3586b; if upcase(source)='ERROR'; actual=ss; run;

data _null_; if 0 then set j3586o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3586 rows=' rows;
else do; set j3586o; if not missing(actual) and abs(actual-(56))<=1e-6*max(1,abs(56)) then put 'ROUND8_PASS=J3586';
else put 'ERROR: ROUND8_FAIL=J3586 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3586:; quit;
