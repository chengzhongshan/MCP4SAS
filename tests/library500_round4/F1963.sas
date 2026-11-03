/* F1963 failure_freq_character_weight, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1963a; length weight $8; do x=1 to 4; weight='4'; output; end; run;
proc freq data=f1963a; tables x; weight weight; run;

proc datasets library=work nolist; delete f1963:; quit;
