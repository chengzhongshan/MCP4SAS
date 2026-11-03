/* J3955 failure_scalar_multiple_rows, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3955a; x=6; run; data j3955b; do y=1 to 6; output; end; run;
proc sql; create table j3955o as select x+(select y from j3955b) as actual from j3955a; quit;

proc datasets library=work nolist; delete j3955:; quit;
