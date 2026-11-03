/* B3307 ttest_paired_statistics, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3307a; do before=1 to 8+2; after=0; output; end; run;
ods output Statistics=b3307b;
proc ttest data=b3307a; paired before*after; run;
ods output close;
data b3307o; set b3307b; actual=mean; run;

data _null_; if 0 then set b3307o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3307 rows=' rows;
else do; set b3307o; if not missing(actual) and abs(actual-(5.5))<=1e-9*max(1,abs(5.5)) then put 'ROUND7_PASS=B3307';
else put 'ERROR: ROUND7_FAIL=B3307 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3307:; quit;
