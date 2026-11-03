/* B3294 ttest_one_sample_statistics, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3294a; do x=1 to 5+2; output; end; run;
ods output Statistics=b3294b;
proc ttest data=b3294a h0=0; var x; run;
ods output close;
data b3294o; set b3294b; actual=mean; run;

data _null_; if 0 then set b3294o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3294 rows=' rows;
else do; set b3294o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND7_PASS=B3294';
else put 'ERROR: ROUND7_FAIL=B3294 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3294:; quit;
