/* F1734 reg_slope, N=5; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1734a; do x=1 to 5+2; y=5+6*x; output; end; run;
proc reg data=f1734a outest=f1734b noprint; model y=x; quit;
data f1734o; set f1734b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1734o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1734 rows=' rows;
else do; set f1734o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1734';
else put 'ERROR: ROUND4_FAIL=F1734 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1734:; quit;
