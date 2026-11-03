/* F1961 failure_freq_character_weight, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1961a; length weight $8; do x=1 to 2; weight='2'; output; end; run;
proc freq data=f1961a; tables x; weight weight; run;

proc datasets library=work nolist; delete f1961:; quit;
