/* J3597 anova_model_ss, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3597a; do grp=1 to 2; do j=1 to 8; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3597b;
proc anova data=j3597a; class grp; model y=grp; run; quit;
ods output close;
data j3597o; set j3597b; if upcase(source)='MODEL'; actual=ss; run;

data _null_; if 0 then set j3597o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3597 rows=' rows;
else do; set j3597o; if not missing(actual) and abs(actual-(400))<=1e-6*max(1,abs(400)) then put 'ROUND8_PASS=J3597';
else put 'ERROR: ROUND8_FAIL=J3597 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3597:; quit;
