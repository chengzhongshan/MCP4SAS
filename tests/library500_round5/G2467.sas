/* G2467 failure_set_type_conflict, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2467a; value=8; run;
data g2467b; length value $12; value='8'; run;
data g2467c; set g2467a g2467b; run;

proc datasets library=work nolist; delete g2467:; quit;
