/* B3273 mixed_intercept_estimate, N=4; source: SAS System for Mixed Models.txt:52 */

data b3273a; do y=1 to 4+2; output; end; run;
ods output SolutionF=b3273b;
proc mixed data=b3273a method=reml; model y= / solution; run;
ods output close;
data b3273o; set b3273b; actual=estimate; run;

data _null_; if 0 then set b3273o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3273 rows=' rows;
else do; set b3273o; if not missing(actual) and abs(actual-(3.5))<=1e-6*max(1,abs(3.5)) then put 'ROUND7_PASS=B3273';
else put 'ERROR: ROUND7_FAIL=B3273 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3273:; quit;
