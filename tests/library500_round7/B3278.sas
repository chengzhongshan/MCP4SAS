/* B3278 mixed_intercept_estimate, N=9; source: SAS System for Mixed Models.txt:52 */

data b3278a; do y=1 to 9+2; output; end; run;
ods output SolutionF=b3278b;
proc mixed data=b3278a method=reml; model y= / solution; run;
ods output close;
data b3278o; set b3278b; actual=estimate; run;

data _null_; if 0 then set b3278o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3278 rows=' rows;
else do; set b3278o; if not missing(actual) and abs(actual-(6))<=1e-6*max(1,abs(6)) then put 'ROUND7_PASS=B3278';
else put 'ERROR: ROUND7_FAIL=B3278 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3278:; quit;
