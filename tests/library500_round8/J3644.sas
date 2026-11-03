/* J3644 freq_chisquare_independence, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3644a; do row=1 to 2; do col=1 to 2; count=5; output; end; end; run;
ods output ChiSq=j3644b;
proc freq data=j3644a; tables row*col / chisq; weight count; run;
ods output close;
data j3644o; set j3644b; if statistic='Chi-Square'; actual=value; run;

data _null_; if 0 then set j3644o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3644 rows=' rows;
else do; set j3644o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3644';
else put 'ERROR: ROUND8_FAIL=J3644 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3644:; quit;
