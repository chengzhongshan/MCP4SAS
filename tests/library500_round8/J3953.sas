/* J3953 failure_scalar_multiple_rows, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3953a; x=4; run; data j3953b; do y=1 to 4; output; end; run;
proc sql; create table j3953o as select x+(select y from j3953b) as actual from j3953a; quit;

proc datasets library=work nolist; delete j3953:; quit;
