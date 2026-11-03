/* F1746 reg_weighted_slope, N=7; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1746a; do x=1 to 7+2; weight=x; y=5+8*x; output; end; run;
proc reg data=f1746a outest=f1746b noprint; model y=x; weight weight; quit;
data f1746o; set f1746b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1746o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1746 rows=' rows;
else do; set f1746o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND4_PASS=F1746';
else put 'ERROR: ROUND4_FAIL=F1746 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1746:; quit;
