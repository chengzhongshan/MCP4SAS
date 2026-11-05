/* K4536 failure_invalid_sysevalf_conversion, N=7; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */

%let k4536v=%sysevalf(7+0.5,not_a_conversion); %symdel k4536v / nowarn;

proc datasets library=work nolist; delete k4536:; quit;
