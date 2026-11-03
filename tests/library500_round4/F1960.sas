/* F1960 failure_reg_missing_response, N=11; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1960a; do x=1 to 11+2; y=x; output; end; run;
proc reg data=f1960a noprint; model f1960absent=x; quit;

proc datasets library=work nolist; delete f1960:; quit;
