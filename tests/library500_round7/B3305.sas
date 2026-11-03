/* B3305 ttest_paired_statistics, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3305a; do before=1 to 6+2; after=0; output; end; run;
ods output Statistics=b3305b;
proc ttest data=b3305a; paired before*after; run;
ods output close;
data b3305o; set b3305b; actual=mean; run;

data _null_; if 0 then set b3305o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3305 rows=' rows;
else do; set b3305o; if not missing(actual) and abs(actual-(4.5))<=1e-9*max(1,abs(4.5)) then put 'ROUND7_PASS=B3305';
else put 'ERROR: ROUND7_FAIL=B3305 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3305:; quit;
