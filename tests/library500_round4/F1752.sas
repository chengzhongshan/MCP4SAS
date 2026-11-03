/* F1752 reg_prediction, N=3; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1752a; do x=1 to 3+2; y=2*x+3; output; end; run;
proc reg data=f1752a noprint; model y=x; output out=f1752b p=predicted; quit;
proc sql; create table f1752o as select max(abs(predicted-y)) as actual from f1752b; quit;

data _null_; if 0 then set f1752o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1752 rows=' rows;
else do; set f1752o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1752';
else put 'ERROR: ROUND4_FAIL=F1752 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1752:; quit;
