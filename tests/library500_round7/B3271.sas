/* B3271 mixed_intercept_estimate, N=2; source: SAS System for Mixed Models.txt:52 */

data b3271a; do y=1 to 2+2; output; end; run;
ods output SolutionF=b3271b;
proc mixed data=b3271a method=reml; model y= / solution; run;
ods output close;
data b3271o; set b3271b; actual=estimate; run;

data _null_; if 0 then set b3271o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3271 rows=' rows;
else do; set b3271o; if not missing(actual) and abs(actual-(2.5))<=1e-6*max(1,abs(2.5)) then put 'ROUND7_PASS=B3271';
else put 'ERROR: ROUND7_FAIL=B3271 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3271:; quit;
