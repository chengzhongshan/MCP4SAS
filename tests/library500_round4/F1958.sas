/* F1958 failure_reg_missing_response, N=9; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1958a; do x=1 to 9+2; y=x; output; end; run;
proc reg data=f1958a noprint; model f1958absent=x; quit;

proc datasets library=work nolist; delete f1958:; quit;
