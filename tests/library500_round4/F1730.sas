/* F1730 reg_intercept, N=11; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1730a; do x=1 to 11+2; y=11+3*x; output; end; run;
proc reg data=f1730a outest=f1730b noprint; model y=x; quit;
data f1730o; set f1730b; if _type_='PARMS'; actual=intercept; run;

data _null_; if 0 then set f1730o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1730 rows=' rows;
else do; set f1730o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND4_PASS=F1730';
else put 'ERROR: ROUND4_FAIL=F1730 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1730:; quit;
