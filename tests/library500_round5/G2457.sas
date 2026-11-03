/* G2457 failure_unique_index, N=8; source: SAS-Useful-Codes/Macros/Bed2SAS_DB.sas:28 */

data g2457a; do k=1 to 8; output; output; end; run;
proc datasets library=work nolist; modify g2457a; index create k / unique; quit;

proc datasets library=work nolist; delete g2457:; quit;
