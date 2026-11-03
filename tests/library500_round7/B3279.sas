/* B3279 mixed_intercept_estimate, N=10; source: SAS System for Mixed Models.txt:52 */

data b3279a; do y=1 to 10+2; output; end; run;
ods output SolutionF=b3279b;
proc mixed data=b3279a method=reml; model y= / solution; run;
ods output close;
data b3279o; set b3279b; actual=estimate; run;

data _null_; if 0 then set b3279o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3279 rows=' rows;
else do; set b3279o; if not missing(actual) and abs(actual-(6.5))<=1e-6*max(1,abs(6.5)) then put 'ROUND7_PASS=B3279';
else put 'ERROR: ROUND7_FAIL=B3279 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3279:; quit;
