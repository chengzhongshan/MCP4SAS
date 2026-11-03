/* B3275 mixed_intercept_estimate, N=6; source: SAS System for Mixed Models.txt:52 */

data b3275a; do y=1 to 6+2; output; end; run;
ods output SolutionF=b3275b;
proc mixed data=b3275a method=reml; model y= / solution; run;
ods output close;
data b3275o; set b3275b; actual=estimate; run;

data _null_; if 0 then set b3275o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3275 rows=' rows;
else do; set b3275o; if not missing(actual) and abs(actual-(4.5))<=1e-6*max(1,abs(4.5)) then put 'ROUND7_PASS=B3275';
else put 'ERROR: ROUND7_FAIL=B3275 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3275:; quit;
