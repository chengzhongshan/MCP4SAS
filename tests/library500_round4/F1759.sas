/* F1759 reg_prediction, N=10; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1759a; do x=1 to 10+2; y=2*x+10; output; end; run;
proc reg data=f1759a noprint; model y=x; output out=f1759b p=predicted; quit;
proc sql; create table f1759o as select max(abs(predicted-y)) as actual from f1759b; quit;

data _null_; if 0 then set f1759o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1759 rows=' rows;
else do; set f1759o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1759';
else put 'ERROR: ROUND4_FAIL=F1759 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1759:; quit;
