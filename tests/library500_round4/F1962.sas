/* F1962 failure_freq_character_weight, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1962a; length weight $8; do x=1 to 3; weight='3'; output; end; run;
proc freq data=f1962a; tables x; weight weight; run;

proc datasets library=work nolist; delete f1962:; quit;
