/* K4548 failure_array_subscript_upper_bound, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4548a; array values{2} x y; i=9+2; values{i}=1; run;

proc datasets library=work nolist; delete k4548:; quit;
