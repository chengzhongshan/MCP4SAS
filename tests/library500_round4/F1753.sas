/* F1753 reg_prediction, N=4; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1753a; do x=1 to 4+2; y=2*x+4; output; end; run;
proc reg data=f1753a noprint; model y=x; output out=f1753b p=predicted; quit;
proc sql; create table f1753o as select max(abs(predicted-y)) as actual from f1753b; quit;

data _null_; if 0 then set f1753o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1753 rows=' rows;
else do; set f1753o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1753';
else put 'ERROR: ROUND4_FAIL=F1753 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1753:; quit;
