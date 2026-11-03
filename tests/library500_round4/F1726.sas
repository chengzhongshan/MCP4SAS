/* F1726 reg_intercept, N=7; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1726a; do x=1 to 7+2; y=7+3*x; output; end; run;
proc reg data=f1726a outest=f1726b noprint; model y=x; quit;
data f1726o; set f1726b; if _type_='PARMS'; actual=intercept; run;

data _null_; if 0 then set f1726o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1726 rows=' rows;
else do; set f1726o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND4_PASS=F1726';
else put 'ERROR: ROUND4_FAIL=F1726 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1726:; quit;
