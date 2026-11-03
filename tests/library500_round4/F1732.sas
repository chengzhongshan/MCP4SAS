/* F1732 reg_slope, N=3; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1732a; do x=1 to 3+2; y=5+4*x; output; end; run;
proc reg data=f1732a outest=f1732b noprint; model y=x; quit;
data f1732o; set f1732b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1732o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1732 rows=' rows;
else do; set f1732o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND4_PASS=F1732';
else put 'ERROR: ROUND4_FAIL=F1732 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1732:; quit;
