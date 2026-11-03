/* H2973 failure_corr_character_variable, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data h2973a; length text $12; do x=1 to 4; text='4'; output; end; run;
proc corr data=h2973a; var text x; run;

proc datasets library=work nolist; delete h2973:; quit;
