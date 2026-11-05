/* K4546 failure_array_subscript_upper_bound, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4546a; array values{2} x y; i=7+2; values{i}=1; run;

proc datasets library=work nolist; delete k4546:; quit;
