/* G2453 failure_unique_index, N=4; source: SAS-Useful-Codes/Macros/Bed2SAS_DB.sas:28 */

data g2453a; do k=1 to 4; output; output; end; run;
proc datasets library=work nolist; modify g2453a; index create k / unique; quit;

proc datasets library=work nolist; delete g2453:; quit;
