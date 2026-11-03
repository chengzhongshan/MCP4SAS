/* B3304 ttest_paired_statistics, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3304a; do before=1 to 5+2; after=0; output; end; run;
ods output Statistics=b3304b;
proc ttest data=b3304a; paired before*after; run;
ods output close;
data b3304o; set b3304b; actual=mean; run;

data _null_; if 0 then set b3304o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3304 rows=' rows;
else do; set b3304o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND7_PASS=B3304';
else put 'ERROR: ROUND7_FAIL=B3304 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3304:; quit;
