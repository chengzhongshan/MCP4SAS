/* J3647 freq_chisquare_independence, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3647a; do row=1 to 2; do col=1 to 2; count=8; output; end; end; run;
ods output ChiSq=j3647b;
proc freq data=j3647a; tables row*col / chisq; weight count; run;
ods output close;
data j3647o; set j3647b; if statistic='Chi-Square'; actual=value; run;

data _null_; if 0 then set j3647o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3647 rows=' rows;
else do; set j3647o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3647';
else put 'ERROR: ROUND8_FAIL=J3647 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3647:; quit;
