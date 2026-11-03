/* H2978 failure_corr_character_variable, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data h2978a; length text $12; do x=1 to 9; text='9'; output; end; run;
proc corr data=h2978a; var text x; run;

proc datasets library=work nolist; delete h2978:; quit;
