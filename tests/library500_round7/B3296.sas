/* B3296 ttest_one_sample_statistics, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3296a; do x=1 to 7+2; output; end; run;
ods output Statistics=b3296b;
proc ttest data=b3296a h0=0; var x; run;
ods output close;
data b3296o; set b3296b; actual=mean; run;

data _null_; if 0 then set b3296o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3296 rows=' rows;
else do; set b3296o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND7_PASS=B3296';
else put 'ERROR: ROUND7_FAIL=B3296 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3296:; quit;
