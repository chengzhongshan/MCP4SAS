/* F1723 reg_intercept, N=4; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1723a; do x=1 to 4+2; y=4+3*x; output; end; run;
proc reg data=f1723a outest=f1723b noprint; model y=x; quit;
data f1723o; set f1723b; if _type_='PARMS'; actual=intercept; run;

data _null_; if 0 then set f1723o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1723 rows=' rows;
else do; set f1723o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND4_PASS=F1723';
else put 'ERROR: ROUND4_FAIL=F1723 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1723:; quit;
