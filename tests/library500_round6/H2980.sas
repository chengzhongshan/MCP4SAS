/* H2980 failure_corr_character_variable, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data h2980a; length text $12; do x=1 to 11; text='11'; output; end; run;
proc corr data=h2980a; var text x; run;

proc datasets library=work nolist; delete h2980:; quit;
