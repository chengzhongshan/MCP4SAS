/* F1743 reg_weighted_slope, N=4; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1743a; do x=1 to 4+2; weight=x; y=5+5*x; output; end; run;
proc reg data=f1743a outest=f1743b noprint; model y=x; weight weight; quit;
data f1743o; set f1743b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1743o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1743 rows=' rows;
else do; set f1743o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1743';
else put 'ERROR: ROUND4_FAIL=F1743 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1743:; quit;
