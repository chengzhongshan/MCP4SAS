/* B3272 mixed_intercept_estimate, N=3; source: SAS System for Mixed Models.txt:52 */

data b3272a; do y=1 to 3+2; output; end; run;
ods output SolutionF=b3272b;
proc mixed data=b3272a method=reml; model y= / solution; run;
ods output close;
data b3272o; set b3272b; actual=estimate; run;

data _null_; if 0 then set b3272o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3272 rows=' rows;
else do; set b3272o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND7_PASS=B3272';
else put 'ERROR: ROUND7_FAIL=B3272 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3272:; quit;
