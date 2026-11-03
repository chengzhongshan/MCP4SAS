/* B3309 ttest_paired_statistics, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3309a; do before=1 to 10+2; after=0; output; end; run;
ods output Statistics=b3309b;
proc ttest data=b3309a; paired before*after; run;
ods output close;
data b3309o; set b3309b; actual=mean; run;

data _null_; if 0 then set b3309o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3309 rows=' rows;
else do; set b3309o; if not missing(actual) and abs(actual-(6.5))<=1e-9*max(1,abs(6.5)) then put 'ROUND7_PASS=B3309';
else put 'ERROR: ROUND7_FAIL=B3309 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3309:; quit;
