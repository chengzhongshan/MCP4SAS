/* F1951 failure_reg_missing_response, N=2; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1951a; do x=1 to 2+2; y=x; output; end; run;
proc reg data=f1951a noprint; model f1951absent=x; quit;

proc datasets library=work nolist; delete f1951:; quit;
