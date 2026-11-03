/* J3960 failure_scalar_multiple_rows, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3960a; x=11; run; data j3960b; do y=1 to 11; output; end; run;
proc sql; create table j3960o as select x+(select y from j3960b) as actual from j3960a; quit;

proc datasets library=work nolist; delete j3960:; quit;
