/* G2485 failure_insert_arity, N=6; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data g2485a; x=6; y=7; run;
proc sql; insert into g2485a(x,y) values(6); quit;

proc datasets library=work nolist; delete g2485:; quit;
