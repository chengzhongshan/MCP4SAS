/* F1725 reg_intercept, N=6; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1725a; do x=1 to 6+2; y=6+3*x; output; end; run;
proc reg data=f1725a outest=f1725b noprint; model y=x; quit;
data f1725o; set f1725b; if _type_='PARMS'; actual=intercept; run;

data _null_; if 0 then set f1725o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1725 rows=' rows;
else do; set f1725o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1725';
else put 'ERROR: ROUND4_FAIL=F1725 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1725:; quit;
