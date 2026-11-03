/* B3277 mixed_intercept_estimate, N=8; source: SAS System for Mixed Models.txt:52 */

data b3277a; do y=1 to 8+2; output; end; run;
ods output SolutionF=b3277b;
proc mixed data=b3277a method=reml; model y= / solution; run;
ods output close;
data b3277o; set b3277b; actual=estimate; run;

data _null_; if 0 then set b3277o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3277 rows=' rows;
else do; set b3277o; if not missing(actual) and abs(actual-(5.5))<=1e-6*max(1,abs(5.5)) then put 'ROUND7_PASS=B3277';
else put 'ERROR: ROUND7_FAIL=B3277 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3277:; quit;
