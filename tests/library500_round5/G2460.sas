/* G2460 failure_unique_index, N=11; source: SAS-Useful-Codes/Macros/Bed2SAS_DB.sas:28 */

data g2460a; do k=1 to 11; output; output; end; run;
proc datasets library=work nolist; modify g2460a; index create k / unique; quit;

proc datasets library=work nolist; delete g2460:; quit;
