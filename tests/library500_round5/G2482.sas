/* G2482 failure_insert_arity, N=3; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data g2482a; x=3; y=4; run;
proc sql; insert into g2482a(x,y) values(3); quit;

proc datasets library=work nolist; delete g2482:; quit;
