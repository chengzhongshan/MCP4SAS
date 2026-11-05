/* K4549 failure_array_subscript_upper_bound, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4549a; array values{2} x y; i=10+2; values{i}=1; run;

proc datasets library=work nolist; delete k4549:; quit;
