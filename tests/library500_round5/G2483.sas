/* G2483 failure_insert_arity, N=4; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data g2483a; x=4; y=5; run;
proc sql; insert into g2483a(x,y) values(4); quit;

proc datasets library=work nolist; delete g2483:; quit;
