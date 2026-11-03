/* G2451 failure_unique_index, N=2; source: SAS-Useful-Codes/Macros/Bed2SAS_DB.sas:28 */

data g2451a; do k=1 to 2; output; output; end; run;
proc datasets library=work nolist; modify g2451a; index create k / unique; quit;

proc datasets library=work nolist; delete g2451:; quit;
