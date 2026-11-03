/* B3303 ttest_paired_statistics, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3303a; do before=1 to 4+2; after=0; output; end; run;
ods output Statistics=b3303b;
proc ttest data=b3303a; paired before*after; run;
ods output close;
data b3303o; set b3303b; actual=mean; run;

data _null_; if 0 then set b3303o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3303 rows=' rows;
else do; set b3303o; if not missing(actual) and abs(actual-(3.5))<=1e-9*max(1,abs(3.5)) then put 'ROUND7_PASS=B3303';
else put 'ERROR: ROUND7_FAIL=B3303 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3303:; quit;
