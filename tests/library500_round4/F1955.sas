/* F1955 failure_reg_missing_response, N=6; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1955a; do x=1 to 6+2; y=x; output; end; run;
proc reg data=f1955a noprint; model f1955absent=x; quit;

proc datasets library=work nolist; delete f1955:; quit;
