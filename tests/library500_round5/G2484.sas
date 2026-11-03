/* G2484 failure_insert_arity, N=5; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data g2484a; x=5; y=6; run;
proc sql; insert into g2484a(x,y) values(5); quit;

proc datasets library=work nolist; delete g2484:; quit;
