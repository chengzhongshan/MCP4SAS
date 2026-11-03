/* F1739 reg_slope, N=10; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1739a; do x=1 to 10+2; y=5+11*x; output; end; run;
proc reg data=f1739a outest=f1739b noprint; model y=x; quit;
data f1739o; set f1739b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1739o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1739 rows=' rows;
else do; set f1739o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND4_PASS=F1739';
else put 'ERROR: ROUND4_FAIL=F1739 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1739:; quit;
