/* G2487 failure_insert_arity, N=8; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data g2487a; x=8; y=9; run;
proc sql; insert into g2487a(x,y) values(8); quit;

proc datasets library=work nolist; delete g2487:; quit;
