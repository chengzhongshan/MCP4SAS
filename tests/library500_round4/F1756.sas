/* F1756 reg_prediction, N=7; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1756a; do x=1 to 7+2; y=2*x+7; output; end; run;
proc reg data=f1756a noprint; model y=x; output out=f1756b p=predicted; quit;
proc sql; create table f1756o as select max(abs(predicted-y)) as actual from f1756b; quit;

data _null_; if 0 then set f1756o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1756 rows=' rows;
else do; set f1756o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1756';
else put 'ERROR: ROUND4_FAIL=F1756 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1756:; quit;
