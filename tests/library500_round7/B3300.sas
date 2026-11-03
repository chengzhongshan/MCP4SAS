/* B3300 ttest_one_sample_statistics, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3300a; do x=1 to 11+2; output; end; run;
ods output Statistics=b3300b;
proc ttest data=b3300a h0=0; var x; run;
ods output close;
data b3300o; set b3300b; actual=mean; run;

data _null_; if 0 then set b3300o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3300 rows=' rows;
else do; set b3300o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND7_PASS=B3300';
else put 'ERROR: ROUND7_FAIL=B3300 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3300:; quit;
