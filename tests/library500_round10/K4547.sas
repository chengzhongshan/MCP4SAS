/* K4547 failure_array_subscript_upper_bound, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4547a; array values{2} x y; i=8+2; values{i}=1; run;

proc datasets library=work nolist; delete k4547:; quit;
