/* G2481 failure_insert_arity, N=2; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data g2481a; x=2; y=3; run;
proc sql; insert into g2481a(x,y) values(2); quit;

proc datasets library=work nolist; delete g2481:; quit;
