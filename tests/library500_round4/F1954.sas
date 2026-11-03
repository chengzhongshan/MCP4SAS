/* F1954 failure_reg_missing_response, N=5; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1954a; do x=1 to 5+2; y=x; output; end; run;
proc reg data=f1954a noprint; model f1954absent=x; quit;

proc datasets library=work nolist; delete f1954:; quit;
