/* H2971 failure_corr_character_variable, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data h2971a; length text $12; do x=1 to 2; text='2'; output; end; run;
proc corr data=h2971a; var text x; run;

proc datasets library=work nolist; delete h2971:; quit;
