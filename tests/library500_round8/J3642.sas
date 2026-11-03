/* J3642 freq_chisquare_independence, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3642a; do row=1 to 2; do col=1 to 2; count=3; output; end; end; run;
ods output ChiSq=j3642b;
proc freq data=j3642a; tables row*col / chisq; weight count; run;
ods output close;
data j3642o; set j3642b; if statistic='Chi-Square'; actual=value; run;

data _null_; if 0 then set j3642o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3642 rows=' rows;
else do; set j3642o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3642';
else put 'ERROR: ROUND8_FAIL=J3642 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3642:; quit;
