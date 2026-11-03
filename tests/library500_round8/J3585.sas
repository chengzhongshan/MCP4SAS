/* J3585 anova_error_ss, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3585a; do grp=1 to 2; do j=1 to 6; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3585b;
proc anova data=j3585a; class grp; model y=grp; run; quit;
ods output close;
data j3585o; set j3585b; if upcase(source)='ERROR'; actual=ss; run;

data _null_; if 0 then set j3585o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3585 rows=' rows;
else do; set j3585o; if not missing(actual) and abs(actual-(35))<=1e-6*max(1,abs(35)) then put 'ROUND8_PASS=J3585';
else put 'ERROR: ROUND8_FAIL=J3585 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3585:; quit;
