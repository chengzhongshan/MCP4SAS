/* F1968 failure_freq_character_weight, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1968a; length weight $8; do x=1 to 9; weight='9'; output; end; run;
proc freq data=f1968a; tables x; weight weight; run;

proc datasets library=work nolist; delete f1968:; quit;
