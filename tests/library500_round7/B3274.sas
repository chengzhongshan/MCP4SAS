/* B3274 mixed_intercept_estimate, N=5; source: SAS System for Mixed Models.txt:52 */

data b3274a; do y=1 to 5+2; output; end; run;
ods output SolutionF=b3274b;
proc mixed data=b3274a method=reml; model y= / solution; run;
ods output close;
data b3274o; set b3274b; actual=estimate; run;

data _null_; if 0 then set b3274o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3274 rows=' rows;
else do; set b3274o; if not missing(actual) and abs(actual-(4))<=1e-6*max(1,abs(4)) then put 'ROUND7_PASS=B3274';
else put 'ERROR: ROUND7_FAIL=B3274 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3274:; quit;
