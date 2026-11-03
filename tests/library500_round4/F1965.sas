/* F1965 failure_freq_character_weight, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1965a; length weight $8; do x=1 to 6; weight='6'; output; end; run;
proc freq data=f1965a; tables x; weight weight; run;

proc datasets library=work nolist; delete f1965:; quit;
