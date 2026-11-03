/* G2456 failure_unique_index, N=7; source: SAS-Useful-Codes/Macros/Bed2SAS_DB.sas:28 */

data g2456a; do k=1 to 7; output; output; end; run;
proc datasets library=work nolist; modify g2456a; index create k / unique; quit;

proc datasets library=work nolist; delete g2456:; quit;
