/* G2455 failure_unique_index, N=6; source: SAS-Useful-Codes/Macros/Bed2SAS_DB.sas:28 */

data g2455a; do k=1 to 6; output; output; end; run;
proc datasets library=work nolist; modify g2455a; index create k / unique; quit;

proc datasets library=work nolist; delete g2455:; quit;
