/* J3951 failure_scalar_multiple_rows, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3951a; x=2; run; data j3951b; do y=1 to 2; output; end; run;
proc sql; create table j3951o as select x+(select y from j3951b) as actual from j3951a; quit;

proc datasets library=work nolist; delete j3951:; quit;
