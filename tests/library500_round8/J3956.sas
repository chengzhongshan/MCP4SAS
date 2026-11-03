/* J3956 failure_scalar_multiple_rows, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3956a; x=7; run; data j3956b; do y=1 to 7; output; end; run;
proc sql; create table j3956o as select x+(select y from j3956b) as actual from j3956a; quit;

proc datasets library=work nolist; delete j3956:; quit;
