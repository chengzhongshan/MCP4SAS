/* B3315 ttest_two_group_difference, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3315a; do grp=1 to 2; do j=1 to 6+2; x=j+10*(grp-1); output; end; end; run;
ods output Statistics=b3315b;
proc ttest data=b3315a; class grp; var x; run;
ods output close;
data b3315o; set b3315b; if index(upcase(class),'DIFF')=1 and upcase(method)='POOLED'; actual=mean; run;

data _null_; if 0 then set b3315o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3315 rows=' rows;
else do; set b3315o; if not missing(actual) and abs(actual-(-10))<=1e-9*max(1,abs(-10)) then put 'ROUND7_PASS=B3315';
else put 'ERROR: ROUND7_FAIL=B3315 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3315:; quit;
