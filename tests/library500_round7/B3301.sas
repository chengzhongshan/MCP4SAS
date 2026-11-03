/* B3301 ttest_paired_statistics, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3301a; do before=1 to 2+2; after=0; output; end; run;
ods output Statistics=b3301b;
proc ttest data=b3301a; paired before*after; run;
ods output close;
data b3301o; set b3301b; actual=mean; run;

data _null_; if 0 then set b3301o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3301 rows=' rows;
else do; set b3301o; if not missing(actual) and abs(actual-(2.5))<=1e-9*max(1,abs(2.5)) then put 'ROUND7_PASS=B3301';
else put 'ERROR: ROUND7_FAIL=B3301 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3301:; quit;
