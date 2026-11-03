/* F1970 failure_freq_character_weight, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1970a; length weight $8; do x=1 to 11; weight='11'; output; end; run;
proc freq data=f1970a; tables x; weight weight; run;

proc datasets library=work nolist; delete f1970:; quit;
