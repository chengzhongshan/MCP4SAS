/* F1964 failure_freq_character_weight, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1964a; length weight $8; do x=1 to 5; weight='5'; output; end; run;
proc freq data=f1964a; tables x; weight weight; run;

proc datasets library=work nolist; delete f1964:; quit;
