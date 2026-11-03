/* J3649 freq_chisquare_independence, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3649a; do row=1 to 2; do col=1 to 2; count=10; output; end; end; run;
ods output ChiSq=j3649b;
proc freq data=j3649a; tables row*col / chisq; weight count; run;
ods output close;
data j3649o; set j3649b; if statistic='Chi-Square'; actual=value; run;

data _null_; if 0 then set j3649o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3649 rows=' rows;
else do; set j3649o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3649';
else put 'ERROR: ROUND8_FAIL=J3649 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3649:; quit;
