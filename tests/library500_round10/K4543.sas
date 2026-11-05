/* K4543 failure_array_subscript_upper_bound, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4543a; array values{2} x y; i=4+2; values{i}=1; run;

proc datasets library=work nolist; delete k4543:; quit;
