/* K4544 failure_array_subscript_upper_bound, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4544a; array values{2} x y; i=5+2; values{i}=1; run;

proc datasets library=work nolist; delete k4544:; quit;
