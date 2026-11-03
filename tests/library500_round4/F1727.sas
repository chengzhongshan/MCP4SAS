/* F1727 reg_intercept, N=8; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1727a; do x=1 to 8+2; y=8+3*x; output; end; run;
proc reg data=f1727a outest=f1727b noprint; model y=x; quit;
data f1727o; set f1727b; if _type_='PARMS'; actual=intercept; run;

data _null_; if 0 then set f1727o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1727 rows=' rows;
else do; set f1727o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND4_PASS=F1727';
else put 'ERROR: ROUND4_FAIL=F1727 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1727:; quit;
