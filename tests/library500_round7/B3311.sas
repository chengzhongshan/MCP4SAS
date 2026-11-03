/* B3311 ttest_two_group_difference, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:212 */

data b3311a; do grp=1 to 2; do j=1 to 2+2; x=j+10*(grp-1); output; end; end; run;
ods output Statistics=b3311b;
proc ttest data=b3311a; class grp; var x; run;
ods output close;
data b3311o; set b3311b; if index(upcase(class),'DIFF')=1 and upcase(method)='POOLED'; actual=mean; run;

data _null_; if 0 then set b3311o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3311 rows=' rows;
else do; set b3311o; if not missing(actual) and abs(actual-(-10))<=1e-9*max(1,abs(-10)) then put 'ROUND7_PASS=B3311';
else put 'ERROR: ROUND7_FAIL=B3311 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3311:; quit;
