/* B3302 ttest_paired_statistics, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3302a; do before=1 to 3+2; after=0; output; end; run;
ods output Statistics=b3302b;
proc ttest data=b3302a; paired before*after; run;
ods output close;
data b3302o; set b3302b; actual=mean; run;

data _null_; if 0 then set b3302o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3302 rows=' rows;
else do; set b3302o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND7_PASS=B3302';
else put 'ERROR: ROUND7_FAIL=B3302 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3302:; quit;
