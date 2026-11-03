/* B3291 ttest_one_sample_statistics, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3291a; do x=1 to 2+2; output; end; run;
ods output Statistics=b3291b;
proc ttest data=b3291a h0=0; var x; run;
ods output close;
data b3291o; set b3291b; actual=mean; run;

data _null_; if 0 then set b3291o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3291 rows=' rows;
else do; set b3291o; if not missing(actual) and abs(actual-(2.5))<=1e-9*max(1,abs(2.5)) then put 'ROUND7_PASS=B3291';
else put 'ERROR: ROUND7_FAIL=B3291 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3291:; quit;
