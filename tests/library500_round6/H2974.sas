/* H2974 failure_corr_character_variable, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data h2974a; length text $12; do x=1 to 5; text='5'; output; end; run;
proc corr data=h2974a; var text x; run;

proc datasets library=work nolist; delete h2974:; quit;
