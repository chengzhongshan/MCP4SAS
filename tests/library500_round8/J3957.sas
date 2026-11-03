/* J3957 failure_scalar_multiple_rows, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3957a; x=8; run; data j3957b; do y=1 to 8; output; end; run;
proc sql; create table j3957o as select x+(select y from j3957b) as actual from j3957a; quit;

proc datasets library=work nolist; delete j3957:; quit;
