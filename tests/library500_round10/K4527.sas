/* K4527 failure_unassigned_output_libref, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3072 */

data Zk4527.out; x=8; run;

proc datasets library=work nolist; delete k4527:; quit;
