/* F1722 reg_intercept, N=3; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1722a; do x=1 to 3+2; y=3+3*x; output; end; run;
proc reg data=f1722a outest=f1722b noprint; model y=x; quit;
data f1722o; set f1722b; if _type_='PARMS'; actual=intercept; run;

data _null_; if 0 then set f1722o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1722 rows=' rows;
else do; set f1722o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND4_PASS=F1722';
else put 'ERROR: ROUND4_FAIL=F1722 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1722:; quit;
