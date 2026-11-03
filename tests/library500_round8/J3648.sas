/* J3648 freq_chisquare_independence, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3648a; do row=1 to 2; do col=1 to 2; count=9; output; end; end; run;
ods output ChiSq=j3648b;
proc freq data=j3648a; tables row*col / chisq; weight count; run;
ods output close;
data j3648o; set j3648b; if statistic='Chi-Square'; actual=value; run;

data _null_; if 0 then set j3648o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3648 rows=' rows;
else do; set j3648o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3648';
else put 'ERROR: ROUND8_FAIL=J3648 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3648:; quit;
