/* B3320 ttest_two_group_difference, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3320a; do grp=1 to 2; do j=1 to 11+2; x=j+10*(grp-1); output; end; end; run;
ods output Statistics=b3320b;
proc ttest data=b3320a; class grp; var x; run;
ods output close;
data b3320o; set b3320b; if index(upcase(class),'DIFF')=1 and upcase(method)='POOLED'; actual=mean; run;

data _null_; if 0 then set b3320o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3320 rows=' rows;
else do; set b3320o; if not missing(actual) and abs(actual-(-10))<=1e-9*max(1,abs(-10)) then put 'ROUND7_PASS=B3320';
else put 'ERROR: ROUND7_FAIL=B3320 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3320:; quit;
