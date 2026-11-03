/* J3592 anova_model_ss, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3592a; do grp=1 to 2; do j=1 to 3; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3592b;
proc anova data=j3592a; class grp; model y=grp; run; quit;
ods output close;
data j3592o; set j3592b; if upcase(source)='MODEL'; actual=ss; run;

data _null_; if 0 then set j3592o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3592 rows=' rows;
else do; set j3592o; if not missing(actual) and abs(actual-(150))<=1e-6*max(1,abs(150)) then put 'ROUND8_PASS=J3592';
else put 'ERROR: ROUND8_FAIL=J3592 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3592:; quit;
