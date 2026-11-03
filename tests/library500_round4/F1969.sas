/* F1969 failure_freq_character_weight, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1969a; length weight $8; do x=1 to 10; weight='10'; output; end; run;
proc freq data=f1969a; tables x; weight weight; run;

proc datasets library=work nolist; delete f1969:; quit;
