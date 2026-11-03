/* F1967 failure_freq_character_weight, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1967a; length weight $8; do x=1 to 8; weight='8'; output; end; run;
proc freq data=f1967a; tables x; weight weight; run;

proc datasets library=work nolist; delete f1967:; quit;
