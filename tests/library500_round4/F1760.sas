/* F1760 reg_prediction, N=11; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1760a; do x=1 to 11+2; y=2*x+11; output; end; run;
proc reg data=f1760a noprint; model y=x; output out=f1760b p=predicted; quit;
proc sql; create table f1760o as select max(abs(predicted-y)) as actual from f1760b; quit;

data _null_; if 0 then set f1760o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1760 rows=' rows;
else do; set f1760o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1760';
else put 'ERROR: ROUND4_FAIL=F1760 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1760:; quit;
