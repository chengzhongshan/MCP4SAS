/* F1721 reg_intercept, N=2; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1721a; do x=1 to 2+2; y=2+3*x; output; end; run;
proc reg data=f1721a outest=f1721b noprint; model y=x; quit;
data f1721o; set f1721b; if _type_='PARMS'; actual=intercept; run;

data _null_; if 0 then set f1721o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1721 rows=' rows;
else do; set f1721o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1721';
else put 'ERROR: ROUND4_FAIL=F1721 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1721:; quit;
