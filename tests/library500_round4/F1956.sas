/* F1956 failure_reg_missing_response, N=7; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1956a; do x=1 to 7+2; y=x; output; end; run;
proc reg data=f1956a noprint; model f1956absent=x; quit;

proc datasets library=work nolist; delete f1956:; quit;
