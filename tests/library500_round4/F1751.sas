/* F1751 reg_prediction, N=2; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1751a; do x=1 to 2+2; y=2*x+2; output; end; run;
proc reg data=f1751a noprint; model y=x; output out=f1751b p=predicted; quit;
proc sql; create table f1751o as select max(abs(predicted-y)) as actual from f1751b; quit;

data _null_; if 0 then set f1751o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1751 rows=' rows;
else do; set f1751o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1751';
else put 'ERROR: ROUND4_FAIL=F1751 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1751:; quit;
