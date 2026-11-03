/* F1742 reg_weighted_slope, N=3; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1742a; do x=1 to 3+2; weight=x; y=5+4*x; output; end; run;
proc reg data=f1742a outest=f1742b noprint; model y=x; weight weight; quit;
data f1742o; set f1742b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1742o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1742 rows=' rows;
else do; set f1742o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND4_PASS=F1742';
else put 'ERROR: ROUND4_FAIL=F1742 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1742:; quit;
