/* G2468 failure_set_type_conflict, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2468a; value=9; run;
data g2468b; length value $12; value='9'; run;
data g2468c; set g2468a g2468b; run;

proc datasets library=work nolist; delete g2468:; quit;
