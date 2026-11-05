/* K4541 failure_array_subscript_upper_bound, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4541a; array values{2} x y; i=2+2; values{i}=1; run;

proc datasets library=work nolist; delete k4541:; quit;
