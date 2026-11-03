/* F1957 failure_reg_missing_response, N=8; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1957a; do x=1 to 8+2; y=x; output; end; run;
proc reg data=f1957a noprint; model f1957absent=x; quit;

proc datasets library=work nolist; delete f1957:; quit;
