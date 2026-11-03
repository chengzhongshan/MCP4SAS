/* F1733 reg_slope, N=4; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1733a; do x=1 to 4+2; y=5+5*x; output; end; run;
proc reg data=f1733a outest=f1733b noprint; model y=x; quit;
data f1733o; set f1733b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1733o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1733 rows=' rows;
else do; set f1733o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1733';
else put 'ERROR: ROUND4_FAIL=F1733 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1733:; quit;
