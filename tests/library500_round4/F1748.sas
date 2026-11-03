/* F1748 reg_weighted_slope, N=9; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1748a; do x=1 to 9+2; weight=x; y=5+10*x; output; end; run;
proc reg data=f1748a outest=f1748b noprint; model y=x; weight weight; quit;
data f1748o; set f1748b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1748o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1748 rows=' rows;
else do; set f1748o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1748';
else put 'ERROR: ROUND4_FAIL=F1748 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1748:; quit;
