/* B3306 ttest_paired_statistics, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3306a; do before=1 to 7+2; after=0; output; end; run;
ods output Statistics=b3306b;
proc ttest data=b3306a; paired before*after; run;
ods output close;
data b3306o; set b3306b; actual=mean; run;

data _null_; if 0 then set b3306o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3306 rows=' rows;
else do; set b3306o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND7_PASS=B3306';
else put 'ERROR: ROUND7_FAIL=B3306 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3306:; quit;
