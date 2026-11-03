/* J3650 freq_chisquare_independence, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3650a; do row=1 to 2; do col=1 to 2; count=11; output; end; end; run;
ods output ChiSq=j3650b;
proc freq data=j3650a; tables row*col / chisq; weight count; run;
ods output close;
data j3650o; set j3650b; if statistic='Chi-Square'; actual=value; run;

data _null_; if 0 then set j3650o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3650 rows=' rows;
else do; set j3650o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3650';
else put 'ERROR: ROUND8_FAIL=J3650 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3650:; quit;
