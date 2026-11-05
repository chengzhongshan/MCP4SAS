/* K4526 failure_unassigned_output_libref, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3072 */

data Zk4526.out; x=7; run;

proc datasets library=work nolist; delete k4526:; quit;
