/* B3297 ttest_one_sample_statistics, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3297a; do x=1 to 8+2; output; end; run;
ods output Statistics=b3297b;
proc ttest data=b3297a h0=0; var x; run;
ods output close;
data b3297o; set b3297b; actual=mean; run;

data _null_; if 0 then set b3297o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3297 rows=' rows;
else do; set b3297o; if not missing(actual) and abs(actual-(5.5))<=1e-9*max(1,abs(5.5)) then put 'ROUND7_PASS=B3297';
else put 'ERROR: ROUND7_FAIL=B3297 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3297:; quit;
