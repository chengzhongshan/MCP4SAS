/* J3952 failure_scalar_multiple_rows, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3952a; x=3; run; data j3952b; do y=1 to 3; output; end; run;
proc sql; create table j3952o as select x+(select y from j3952b) as actual from j3952a; quit;

proc datasets library=work nolist; delete j3952:; quit;
