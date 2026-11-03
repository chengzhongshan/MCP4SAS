/* F1738 reg_slope, N=9; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1738a; do x=1 to 9+2; y=5+10*x; output; end; run;
proc reg data=f1738a outest=f1738b noprint; model y=x; quit;
data f1738o; set f1738b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1738o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1738 rows=' rows;
else do; set f1738o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1738';
else put 'ERROR: ROUND4_FAIL=F1738 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1738:; quit;
