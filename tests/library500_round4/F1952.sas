/* F1952 failure_reg_missing_response, N=3; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1952a; do x=1 to 3+2; y=x; output; end; run;
proc reg data=f1952a noprint; model f1952absent=x; quit;

proc datasets library=work nolist; delete f1952:; quit;
