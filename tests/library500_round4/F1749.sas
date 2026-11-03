/* F1749 reg_weighted_slope, N=10; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1749a; do x=1 to 10+2; weight=x; y=5+11*x; output; end; run;
proc reg data=f1749a outest=f1749b noprint; model y=x; weight weight; quit;
data f1749o; set f1749b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1749o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1749 rows=' rows;
else do; set f1749o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND4_PASS=F1749';
else put 'ERROR: ROUND4_FAIL=F1749 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1749:; quit;
