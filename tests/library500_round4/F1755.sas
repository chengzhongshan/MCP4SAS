/* F1755 reg_prediction, N=6; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1755a; do x=1 to 6+2; y=2*x+6; output; end; run;
proc reg data=f1755a noprint; model y=x; output out=f1755b p=predicted; quit;
proc sql; create table f1755o as select max(abs(predicted-y)) as actual from f1755b; quit;

data _null_; if 0 then set f1755o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1755 rows=' rows;
else do; set f1755o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1755';
else put 'ERROR: ROUND4_FAIL=F1755 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1755:; quit;
