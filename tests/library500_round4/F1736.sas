/* F1736 reg_slope, N=7; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1736a; do x=1 to 7+2; y=5+8*x; output; end; run;
proc reg data=f1736a outest=f1736b noprint; model y=x; quit;
data f1736o; set f1736b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1736o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1736 rows=' rows;
else do; set f1736o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND4_PASS=F1736';
else put 'ERROR: ROUND4_FAIL=F1736 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1736:; quit;
