/* F1744 reg_weighted_slope, N=5; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1744a; do x=1 to 5+2; weight=x; y=5+6*x; output; end; run;
proc reg data=f1744a outest=f1744b noprint; model y=x; weight weight; quit;
data f1744o; set f1744b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1744o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1744 rows=' rows;
else do; set f1744o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1744';
else put 'ERROR: ROUND4_FAIL=F1744 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1744:; quit;
