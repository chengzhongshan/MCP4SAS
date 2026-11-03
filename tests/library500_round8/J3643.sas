/* J3643 freq_chisquare_independence, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:291 */

data j3643a; do row=1 to 2; do col=1 to 2; count=4; output; end; end; run;
ods output ChiSq=j3643b;
proc freq data=j3643a; tables row*col / chisq; weight count; run;
ods output close;
data j3643o; set j3643b; if statistic='Chi-Square'; actual=value; run;

data _null_; if 0 then set j3643o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3643 rows=' rows;
else do; set j3643o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3643';
else put 'ERROR: ROUND8_FAIL=J3643 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3643:; quit;
