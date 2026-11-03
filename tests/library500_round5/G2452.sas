/* G2452 failure_unique_index, N=3; source: SAS-Useful-Codes/Macros/Bed2SAS_DB.sas:28 */

data g2452a; do k=1 to 3; output; output; end; run;
proc datasets library=work nolist; modify g2452a; index create k / unique; quit;

proc datasets library=work nolist; delete g2452:; quit;
