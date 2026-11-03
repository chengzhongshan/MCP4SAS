/* J3954 failure_scalar_multiple_rows, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3954a; x=5; run; data j3954b; do y=1 to 5; output; end; run;
proc sql; create table j3954o as select x+(select y from j3954b) as actual from j3954a; quit;

proc datasets library=work nolist; delete j3954:; quit;
