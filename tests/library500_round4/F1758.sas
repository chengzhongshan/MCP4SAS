/* F1758 reg_prediction, N=9; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1758a; do x=1 to 9+2; y=2*x+9; output; end; run;
proc reg data=f1758a noprint; model y=x; output out=f1758b p=predicted; quit;
proc sql; create table f1758o as select max(abs(predicted-y)) as actual from f1758b; quit;

data _null_; if 0 then set f1758o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1758 rows=' rows;
else do; set f1758o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1758';
else put 'ERROR: ROUND4_FAIL=F1758 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1758:; quit;
