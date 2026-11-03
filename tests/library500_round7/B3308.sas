/* B3308 ttest_paired_statistics, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3308a; do before=1 to 9+2; after=0; output; end; run;
ods output Statistics=b3308b;
proc ttest data=b3308a; paired before*after; run;
ods output close;
data b3308o; set b3308b; actual=mean; run;

data _null_; if 0 then set b3308o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3308 rows=' rows;
else do; set b3308o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3308';
else put 'ERROR: ROUND7_FAIL=B3308 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3308:; quit;
