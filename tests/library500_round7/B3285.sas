/* B3285 mixed_symmetric_slope, N=6; source: SAS System for Mixed Models.txt:52 */

data b3285a; do j=1 to 6; err=(-1)**j; x=-j; y=5+3*x+err; output; x=j; y=5+3*x+err; output; end; run;
ods output SolutionF=b3285b;
proc mixed data=b3285a method=reml; model y=x / solution; run;
ods output close;
data b3285o; set b3285b; if upcase(effect)='X'; actual=estimate; run;

data _null_; if 0 then set b3285o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3285 rows=' rows;
else do; set b3285o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND7_PASS=B3285';
else put 'ERROR: ROUND7_FAIL=B3285 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3285:; quit;
