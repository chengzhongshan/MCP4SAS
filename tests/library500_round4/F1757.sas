/* F1757 reg_prediction, N=8; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1757a; do x=1 to 8+2; y=2*x+8; output; end; run;
proc reg data=f1757a noprint; model y=x; output out=f1757b p=predicted; quit;
proc sql; create table f1757o as select max(abs(predicted-y)) as actual from f1757b; quit;

data _null_; if 0 then set f1757o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1757 rows=' rows;
else do; set f1757o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1757';
else put 'ERROR: ROUND4_FAIL=F1757 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1757:; quit;
