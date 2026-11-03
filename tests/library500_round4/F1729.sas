/* F1729 reg_intercept, N=10; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1729a; do x=1 to 10+2; y=10+3*x; output; end; run;
proc reg data=f1729a outest=f1729b noprint; model y=x; quit;
data f1729o; set f1729b; if _type_='PARMS'; actual=intercept; run;

data _null_; if 0 then set f1729o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1729 rows=' rows;
else do; set f1729o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1729';
else put 'ERROR: ROUND4_FAIL=F1729 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1729:; quit;
