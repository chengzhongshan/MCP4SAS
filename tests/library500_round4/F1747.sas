/* F1747 reg_weighted_slope, N=8; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1747a; do x=1 to 8+2; weight=x; y=5+9*x; output; end; run;
proc reg data=f1747a outest=f1747b noprint; model y=x; weight weight; quit;
data f1747o; set f1747b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1747o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1747 rows=' rows;
else do; set f1747o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND4_PASS=F1747';
else put 'ERROR: ROUND4_FAIL=F1747 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1747:; quit;
