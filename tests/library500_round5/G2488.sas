/* G2488 failure_insert_arity, N=9; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data g2488a; x=9; y=10; run;
proc sql; insert into g2488a(x,y) values(9); quit;

proc datasets library=work nolist; delete g2488:; quit;
