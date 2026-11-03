/* F1754 reg_prediction, N=5; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1754a; do x=1 to 5+2; y=2*x+5; output; end; run;
proc reg data=f1754a noprint; model y=x; output out=f1754b p=predicted; quit;
proc sql; create table f1754o as select max(abs(predicted-y)) as actual from f1754b; quit;

data _null_; if 0 then set f1754o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1754 rows=' rows;
else do; set f1754o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1754';
else put 'ERROR: ROUND4_FAIL=F1754 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1754:; quit;
