/* F1750 reg_weighted_slope, N=11; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1750a; do x=1 to 11+2; weight=x; y=5+12*x; output; end; run;
proc reg data=f1750a outest=f1750b noprint; model y=x; weight weight; quit;
data f1750o; set f1750b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1750o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1750 rows=' rows;
else do; set f1750o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND4_PASS=F1750';
else put 'ERROR: ROUND4_FAIL=F1750 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1750:; quit;
