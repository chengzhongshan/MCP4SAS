/* K4533 failure_invalid_sysevalf_conversion, N=4; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */

%let k4533v=%sysevalf(4+0.5,not_a_conversion); %symdel k4533v / nowarn;

proc datasets library=work nolist; delete k4533:; quit;
