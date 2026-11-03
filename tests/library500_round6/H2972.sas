/* H2972 failure_corr_character_variable, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data h2972a; length text $12; do x=1 to 3; text='3'; output; end; run;
proc corr data=h2972a; var text x; run;

proc datasets library=work nolist; delete h2972:; quit;
