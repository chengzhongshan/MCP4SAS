/* G2486 failure_insert_arity, N=7; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data g2486a; x=7; y=8; run;
proc sql; insert into g2486a(x,y) values(7); quit;

proc datasets library=work nolist; delete g2486:; quit;
