/* B3310 ttest_paired_statistics, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3310a; do before=1 to 11+2; after=0; output; end; run;
ods output Statistics=b3310b;
proc ttest data=b3310a; paired before*after; run;
ods output close;
data b3310o; set b3310b; actual=mean; run;

data _null_; if 0 then set b3310o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3310 rows=' rows;
else do; set b3310o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND7_PASS=B3310';
else put 'ERROR: ROUND7_FAIL=B3310 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3310:; quit;
