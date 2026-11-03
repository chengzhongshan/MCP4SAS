/* J3958 failure_scalar_multiple_rows, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3958a; x=9; run; data j3958b; do y=1 to 9; output; end; run;
proc sql; create table j3958o as select x+(select y from j3958b) as actual from j3958a; quit;

proc datasets library=work nolist; delete j3958:; quit;
