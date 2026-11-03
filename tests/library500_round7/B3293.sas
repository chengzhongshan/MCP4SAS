/* B3293 ttest_one_sample_statistics, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3293a; do x=1 to 4+2; output; end; run;
ods output Statistics=b3293b;
proc ttest data=b3293a h0=0; var x; run;
ods output close;
data b3293o; set b3293b; actual=mean; run;

data _null_; if 0 then set b3293o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3293 rows=' rows;
else do; set b3293o; if not missing(actual) and abs(actual-(3.5))<=1e-9*max(1,abs(3.5)) then put 'ROUND7_PASS=B3293';
else put 'ERROR: ROUND7_FAIL=B3293 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3293:; quit;
