/* F1731 reg_slope, N=2; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1731a; do x=1 to 2+2; y=5+3*x; output; end; run;
proc reg data=f1731a outest=f1731b noprint; model y=x; quit;
data f1731o; set f1731b; if _type_='PARMS'; actual=x; run;

data _null_; if 0 then set f1731o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1731 rows=' rows;
else do; set f1731o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND4_PASS=F1731';
else put 'ERROR: ROUND4_FAIL=F1731 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1731:; quit;
