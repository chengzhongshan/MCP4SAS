/* G2459 failure_unique_index, N=10; source: SAS-Useful-Codes/Macros/Bed2SAS_DB.sas:28 */

data g2459a; do k=1 to 10; output; output; end; run;
proc datasets library=work nolist; modify g2459a; index create k / unique; quit;

proc datasets library=work nolist; delete g2459:; quit;
