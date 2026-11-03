/* F1741 reg_weighted_slope, N=2; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1741a; do x=1 to 2+2; weight=x; y=5+3*x; output; end; run;
proc reg data=f1741a outest=f1741b noprint; model y=x; weight weight; quit;
data f1741o; set f1741b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1741o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1741 rows=' rows;
else do; set f1741o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND4_PASS=F1741';
else put 'ERROR: ROUND4_FAIL=F1741 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1741:; quit;
