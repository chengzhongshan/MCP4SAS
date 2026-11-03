/* B3299 ttest_one_sample_statistics, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3299a; do x=1 to 10+2; output; end; run;
ods output Statistics=b3299b;
proc ttest data=b3299a h0=0; var x; run;
ods output close;
data b3299o; set b3299b; actual=mean; run;

data _null_; if 0 then set b3299o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3299 rows=' rows;
else do; set b3299o; if not missing(actual) and abs(actual-(6.5))<=1e-9*max(1,abs(6.5)) then put 'ROUND7_PASS=B3299';
else put 'ERROR: ROUND7_FAIL=B3299 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3299:; quit;
