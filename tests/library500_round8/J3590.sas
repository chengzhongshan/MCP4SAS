/* J3590 anova_error_ss, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:606 */

data j3590a; do grp=1 to 2; do j=1 to 11; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=j3590b;
proc anova data=j3590a; class grp; model y=grp; run; quit;
ods output close;
data j3590o; set j3590b; if upcase(source)='ERROR'; actual=ss; run;

data _null_; if 0 then set j3590o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3590 rows=' rows;
else do; set j3590o; if not missing(actual) and abs(actual-(220))<=1e-6*max(1,abs(220)) then put 'ROUND8_PASS=J3590';
else put 'ERROR: ROUND8_FAIL=J3590 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3590:; quit;
