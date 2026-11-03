/* G2489 failure_insert_arity, N=10; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data g2489a; x=10; y=11; run;
proc sql; insert into g2489a(x,y) values(10); quit;

proc datasets library=work nolist; delete g2489:; quit;
