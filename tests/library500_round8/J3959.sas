/* J3959 failure_scalar_multiple_rows, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3959a; x=10; run; data j3959b; do y=1 to 10; output; end; run;
proc sql; create table j3959o as select x+(select y from j3959b) as actual from j3959a; quit;

proc datasets library=work nolist; delete j3959:; quit;
