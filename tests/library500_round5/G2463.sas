/* G2463 failure_set_type_conflict, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2463a; value=4; run;
data g2463b; length value $12; value='4'; run;
data g2463c; set g2463a g2463b; run;

proc datasets library=work nolist; delete g2463:; quit;
