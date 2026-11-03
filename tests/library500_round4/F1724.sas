/* F1724 reg_intercept, N=5; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1724a; do x=1 to 5+2; y=5+3*x; output; end; run;
proc reg data=f1724a outest=f1724b noprint; model y=x; quit;
data f1724o; set f1724b; if _type_='PARMS'; actual=intercept; run;

data _null_; if 0 then set f1724o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1724 rows=' rows;
else do; set f1724o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1724';
else put 'ERROR: ROUND4_FAIL=F1724 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1724:; quit;
