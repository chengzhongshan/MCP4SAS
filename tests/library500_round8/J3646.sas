/* J3646 freq_chisquare_independence, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3646a; do row=1 to 2; do col=1 to 2; count=7; output; end; end; run;
ods output ChiSq=j3646b;
proc freq data=j3646a; tables row*col / chisq; weight count; run;
ods output close;
data j3646o; set j3646b; if statistic='Chi-Square'; actual=value; run;

data _null_; if 0 then set j3646o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3646 rows=' rows;
else do; set j3646o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3646';
else put 'ERROR: ROUND8_FAIL=J3646 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3646:; quit;
