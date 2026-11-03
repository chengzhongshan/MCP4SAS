/* B3276 mixed_intercept_estimate, N=7; source: SAS System for Mixed Models.txt:52 */

data b3276a; do y=1 to 7+2; output; end; run;
ods output SolutionF=b3276b;
proc mixed data=b3276a method=reml; model y= / solution; run;
ods output close;
data b3276o; set b3276b; actual=estimate; run;

data _null_; if 0 then set b3276o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3276 rows=' rows;
else do; set b3276o; if not missing(actual) and abs(actual-(5))<=1e-6*max(1,abs(5)) then put 'ROUND7_PASS=B3276';
else put 'ERROR: ROUND7_FAIL=B3276 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3276:; quit;
