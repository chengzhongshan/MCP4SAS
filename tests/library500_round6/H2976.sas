/* H2976 failure_corr_character_variable, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data h2976a; length text $12; do x=1 to 7; text='7'; output; end; run;
proc corr data=h2976a; var text x; run;

proc datasets library=work nolist; delete h2976:; quit;
