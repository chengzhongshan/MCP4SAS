/* F1735 reg_slope, N=6; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1735a; do x=1 to 6+2; y=5+7*x; output; end; run;
proc reg data=f1735a outest=f1735b noprint; model y=x; quit;
data f1735o; set f1735b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1735o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1735 rows=' rows;
else do; set f1735o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND4_PASS=F1735';
else put 'ERROR: ROUND4_FAIL=F1735 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1735:; quit;
