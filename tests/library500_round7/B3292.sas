/* B3292 ttest_one_sample_statistics, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3292a; do x=1 to 3+2; output; end; run;
ods output Statistics=b3292b;
proc ttest data=b3292a h0=0; var x; run;
ods output close;
data b3292o; set b3292b; actual=mean; run;

data _null_; if 0 then set b3292o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3292 rows=' rows;
else do; set b3292o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND7_PASS=B3292';
else put 'ERROR: ROUND7_FAIL=B3292 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3292:; quit;
