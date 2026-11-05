/* K4542 failure_array_subscript_upper_bound, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4542a; array values{2} x y; i=3+2; values{i}=1; run;

proc datasets library=work nolist; delete k4542:; quit;
