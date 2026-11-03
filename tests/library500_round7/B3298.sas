/* B3298 ttest_one_sample_statistics, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3298a; do x=1 to 9+2; output; end; run;
ods output Statistics=b3298b;
proc ttest data=b3298a h0=0; var x; run;
ods output close;
data b3298o; set b3298b; actual=mean; run;

data _null_; if 0 then set b3298o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3298 rows=' rows;
else do; set b3298o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3298';
else put 'ERROR: ROUND7_FAIL=B3298 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3298:; quit;
