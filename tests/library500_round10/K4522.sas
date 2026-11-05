/* K4522 failure_unassigned_output_libref, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3072 */

data Zk4522.out; x=3; run;

proc datasets library=work nolist; delete k4522:; quit;
