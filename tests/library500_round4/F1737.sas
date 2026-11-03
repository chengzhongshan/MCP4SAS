/* F1737 reg_slope, N=8; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1737a; do x=1 to 8+2; y=5+9*x; output; end; run;
proc reg data=f1737a outest=f1737b noprint; model y=x; quit;
data f1737o; set f1737b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1737o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1737 rows=' rows;
else do; set f1737o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND4_PASS=F1737';
else put 'ERROR: ROUND4_FAIL=F1737 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1737:; quit;
