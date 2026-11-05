/* K4550 failure_array_subscript_upper_bound, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4550a; array values{2} x y; i=11+2; values{i}=1; run;

proc datasets library=work nolist; delete k4550:; quit;
