/* J3641 freq_chisquare_independence, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3641a; do row=1 to 2; do col=1 to 2; count=2; output; end; end; run;
ods output ChiSq=j3641b;
proc freq data=j3641a; tables row*col / chisq; weight count; run;
ods output close;
data j3641o; set j3641b; if statistic='Chi-Square'; actual=value; run;

data _null_; if 0 then set j3641o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3641 rows=' rows;
else do; set j3641o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3641';
else put 'ERROR: ROUND8_FAIL=J3641 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3641:; quit;
