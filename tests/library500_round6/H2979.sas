/* H2979 failure_corr_character_variable, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data h2979a; length text $12; do x=1 to 10; text='10'; output; end; run;
proc corr data=h2979a; var text x; run;

proc datasets library=work nolist; delete h2979:; quit;
