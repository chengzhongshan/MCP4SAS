/* G2490 failure_insert_arity, N=11; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data g2490a; x=11; y=12; run;
proc sql; insert into g2490a(x,y) values(11); quit;

proc datasets library=work nolist; delete g2490:; quit;
