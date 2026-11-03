/* G2458 failure_unique_index, N=9; source: SAS-Useful-Codes/Macros/Bed2SAS_DB.sas:28 */

data g2458a; do k=1 to 9; output; output; end; run;
proc datasets library=work nolist; modify g2458a; index create k / unique; quit;

proc datasets library=work nolist; delete g2458:; quit;
