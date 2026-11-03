/* F1745 reg_weighted_slope, N=6; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1745a; do x=1 to 6+2; weight=x; y=5+7*x; output; end; run;
proc reg data=f1745a outest=f1745b noprint; model y=x; weight weight; quit;
data f1745o; set f1745b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1745o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1745 rows=' rows;
else do; set f1745o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND4_PASS=F1745';
else put 'ERROR: ROUND4_FAIL=F1745 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1745:; quit;
