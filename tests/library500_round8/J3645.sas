/* J3645 freq_chisquare_independence, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3645a; do row=1 to 2; do col=1 to 2; count=6; output; end; end; run;
ods output ChiSq=j3645b;
proc freq data=j3645a; tables row*col / chisq; weight count; run;
ods output close;
data j3645o; set j3645b; if statistic='Chi-Square'; actual=value; run;

data _null_; if 0 then set j3645o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3645 rows=' rows;
else do; set j3645o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3645';
else put 'ERROR: ROUND8_FAIL=J3645 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3645:; quit;
