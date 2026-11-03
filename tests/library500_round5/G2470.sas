/* G2470 failure_set_type_conflict, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2470a; value=11; run;
data g2470b; length value $12; value='11'; run;
data g2470c; set g2470a g2470b; run;

proc datasets library=work nolist; delete g2470:; quit;
