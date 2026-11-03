/* B3286 mixed_symmetric_slope, N=7; source: SAS System for Mixed Models.txt:52 */

data b3286a; do j=1 to 7; err=(-1)**j; x=-j; y=5+3*x+err; output; x=j; y=5+3*x+err; output; end; run;
ods output SolutionF=b3286b;
proc mixed data=b3286a method=reml; model y=x / solution; run;
ods output close;
data b3286o; set b3286b; if upcase(effect)='X'; actual=estimate; run;

data _null_; if 0 then set b3286o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3286 rows=' rows;
else do; set b3286o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND7_PASS=B3286';
else put 'ERROR: ROUND7_FAIL=B3286 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3286:; quit;
