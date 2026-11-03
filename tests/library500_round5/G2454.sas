/* G2454 failure_unique_index, N=5; source: SAS-Useful-Codes/Macros/Bed2SAS_DB.sas:28 */

data g2454a; do k=1 to 5; output; output; end; run;
proc datasets library=work nolist; modify g2454a; index create k / unique; quit;

proc datasets library=work nolist; delete g2454:; quit;
