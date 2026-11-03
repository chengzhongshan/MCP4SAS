/* F1959 failure_reg_missing_response, N=10; source: SAS-Useful-Codes/Macros/HGI2PairwiseGWASPipeline.sas:259 */

data f1959a; do x=1 to 10+2; y=x; output; end; run;
proc reg data=f1959a noprint; model f1959absent=x; quit;

proc datasets library=work nolist; delete f1959:; quit;
