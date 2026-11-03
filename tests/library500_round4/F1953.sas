/* F1953 failure_reg_missing_response, N=4; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1953a; do x=1 to 4+2; y=x; output; end; run;
proc reg data=f1953a noprint; model f1953absent=x; quit;

proc datasets library=work nolist; delete f1953:; quit;
